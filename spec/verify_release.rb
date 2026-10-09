require "bundler/setup"
require "rubygems/package"
require "fileutils"
require "tmpdir"
require "uri"

pipeline, environment = ARGV
abort "Expected pipeline (propshaft|sprockets) and environment (development|production)" unless
  %w[propshaft sprockets].include?(pipeline) && %w[development production].include?(environment)

ENV["ASSET_PIPELINE"] = pipeline
ENV["RAILS_ENV"] = environment

repository = File.expand_path("..", __dir__)
artifact = File.join(repository, "pkg/dfm_web-8.0.0.gem")
package = Gem::Package.new(artifact)
specification = package.spec
abort "Incorrect package version" unless specification.version.to_s == "8.0.0"

required = %w[
  README.md MIT-LICENSE lib/dfm_web.rb lib/dfm_web/version.rb lib/dfm_web/engine.rb lib/dfm_web/railtie.rb
  lib/dfm_web/auto_assets.rb app/helpers/dfm_web_helper.rb
  app/assets/stylesheets/dfm_web/dfm_web.css app/assets/javascripts/dfm_web/dfm_web.js
]
missing = required - specification.files
abort "Missing package files: #{missing.join(', ')}" unless missing.empty?
if specification.files.any? { |path|
  path.start_with?("spec/", "tmp/", "log/") || File.basename(path) == ".DS_Store"
}
  abort "Development files packaged"
end
erb_assets = specification.files.select { |path|
  path.include?("/assets/") && path.end_with?(".erb")
}
abort "ERB assets packaged: #{erb_assets.join(', ')}" unless erb_assets.empty?

Dir.mktmpdir("dfm-web-release-") do |temporary|
  gem_root = File.join(temporary, "gem")
  host_root = File.join(temporary, "host")
  package.extract_files(gem_root)
  FileUtils.mkdir_p(File.join(host_root, "public"))
  %w[config stylesheets javascripts].each do |directory|
    FileUtils.mkdir_p(File.join(host_root, "app/assets", directory))
  end
  File.write(File.join(host_root, "app/assets/config/manifest.js"),
    "//= link application.css\n//= link application.js\n//= link dfm_web/manifest.js\n")
  File.write(File.join(host_root, "app/assets/stylesheets/application.css"),
    ".panel { background-color: lime; }\n")
  File.write(File.join(host_root, "app/assets/javascripts/application.js"),
    "window.releaseHostScriptLoaded = true;\n")

  require "rails"
  require "active_model/railtie"
  require "action_controller/railtie"
  require "action_view/railtie"
  require pipeline == "propshaft" ? "propshaft" : "sprockets/railtie"
  require "rake"
  require "rack/mock"

  $LOAD_PATH.unshift(File.join(gem_root, "lib"))
  require File.join(gem_root, "lib/dfm_web.rb")
  engine_root = File.realpath(DfmWeb::Engine.root.to_s)
  package_root = File.realpath(gem_root)
  unless engine_root == package_root
    abort "Engine is not loaded from the packaged gem: expected #{package_root}, got #{engine_root}"
  end

  module DfmWebReleaseHost
    class Application < Rails::Application
    end

    class PageController < ActionController::Base
      def index
        render html: <<~HTML.html_safe, layout: false
          <!doctype html>
          <html>
            <head>
              <meta charset="utf-8"><title>Packaged DFM host</title>
              #{view_context.stylesheet_link_tag("application")}
              #{view_context.javascript_include_tag("application", defer: true)}
            </head>
            <body><div class="panel">Packaged gem fixture</div></body>
          </html>
        HTML
      end
    end
  end

  application = DfmWebReleaseHost::Application.new
  Rails.application = application
  application.config.root = host_root
  application.config.load_defaults 8.0
  application.config.secret_key_base = "dfm-release-fixture-only-" * 8
  application.config.hosts.clear
  application.config.eager_load = environment == "production"
  application.config.action_dispatch.show_exceptions = :none
  application.config.public_file_server.enabled = true
  application.config.assets.prefix = "/release-assets"
  if pipeline == "sprockets"
    application.config.assets.compile = environment == "development"
    application.config.assets.js_compressor = nil
    application.config.assets.css_compressor = nil
  end
  application.initialize!
  application.routes.draw do
    get "/", to: "dfm_web_release_host/page#index"
  end
  if environment == "production"
    application.load_tasks
    Rake::Task["assets:precompile"].invoke
    if pipeline == "sprockets"
      manifest = Sprockets::Railtie.build_manifest(application)
      application.assets_manifest = manifest
      ActionView::Base.assets_manifest = manifest
    end
  end

  client = Rack::MockRequest.new(application)
  page = client.get("/")
  abort "Host page returned #{page.status}" unless page.status == 200
  document = Nokogiri::HTML5.parse(page.body)
  stylesheet = document.css("head > link[data-dfm-web='stylesheet']")
  script = document.css("head > script[data-dfm-web='script']")
  abort "Automatic package asset inclusion failed" unless stylesheet.length == 1 && script.length == 1
  abort "Host stylesheet precedence lost" unless document.css("head > link[rel~='stylesheet']").first == stylesheet.first

  assets = [
    [stylesheet.first["href"], "text/css"],
    [script.first["src"], "text/javascript"]
  ]
  %w[apple-touch-icon defective_monitor excel uwcrest word].each do |name|
    assets << [ActionController::Base.helpers.asset_path("dfm_web/#{name}.png"), "image/png"]
  end
  assets.each do |url, type|
    path = URI.parse(url).path
    abort "Asset prefix missing: #{url}" unless path.start_with?("/release-assets/")
    if environment == "production"
      abort "Production asset is not fingerprinted: #{url}" unless File.basename(path).match?(/-[0-9a-f]{7,}\./)
    end
    response = client.get(path)
    abort "Asset returned #{response.status}: #{url}" unless response.status == 200
    content_type = response.headers.fetch("content-type").split(";").first
    allowed_types = type == "text/javascript" ? %w[text/javascript application/javascript] : [type]
    abort "Unexpected asset type #{content_type}: #{url}" unless allowed_types.include?(content_type)
    if type == "text/css"
      abort "Stylesheet content missing" unless response.body.include?(".panel {") && response.body.include?("clip-path: shape(evenodd")
      abort "Unprocessed stylesheet served" if response.body.include?("*= require") || response.body.include?("<%")
    elsif type == "text/javascript"
      abort "Portable startup missing" unless response.body.include?("DfmWeb") && response.body.include?("DOMContentLoaded")
    end
  end

  abort "Forbidden local engine dependency" if $LOADED_FEATURES.include?(File.join(repository, "lib/dfm_web/engine.rb"))
  puts "PASS: packaged gem, automatic inclusion, and seven assets (#{pipeline}, #{environment})"
end
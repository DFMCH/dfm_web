require File.expand_path('../boot', __FILE__)

require "active_model/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
pipeline = ENV.fetch("ASSET_PIPELINE", "propshaft")
raise ArgumentError, "Unknown ASSET_PIPELINE: #{pipeline}" unless %w[propshaft sprockets].include?(pipeline)
require pipeline == "propshaft" ? "propshaft" : "sprockets/railtie"


Bundler.require(*Rails.groups)
require "dfm_web"

module Dummy
  class Application < Rails::Application
    config.load_defaults 8.0
    config.secret_key_base = "dfm-web-dummy-" * 10 unless Rails.env.production?
    config.assets.prefix = ENV.fetch("ASSET_PREFIX", "/assets")
    config.action_controller.asset_host = ENV["ASSET_HOST"]
    config.x.with_turbo = ENV["WITH_TURBO"] == "1"
    if config.x.with_turbo
      config.assets.paths << File.join(Gem.loaded_specs.fetch("turbo-rails").full_gem_path, "app/assets/javascripts")
    end
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
  end
end


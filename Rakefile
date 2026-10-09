begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'
require 'rake'
require 'rspec/core/rake_task'


RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'DfmWeb'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.md')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'



Bundler::GemHelper.install_tasks

require_relative "lib/dfm_web/css_bundle"

namespace :dfm_web do
  namespace :assets do
    desc "Build the readable DFM stylesheet bundle"
    task :build do
      DfmWeb::CssBundle.write
    end

    desc "Check that the committed stylesheet bundle matches its sources"
    task :check do
      DfmWeb::CssBundle.check!
    end
  end

  namespace :release do
    desc "Build and verify the packaged gem in isolated development and production hosts"
    task check: :build do
      %w[propshaft sprockets].each do |pipeline|
        %w[development production].each do |environment|
          ruby "spec/verify_release.rb", pipeline, environment
        end
      end
    end
  end
end

task build: "dfm_web:assets:build"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
end


task default: :spec

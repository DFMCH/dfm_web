$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dfm_web/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "dfm_web"
  spec.version     = DfmWeb::VERSION
  spec.authors     = ["Jacob Duffy"]
  spec.email       = ["duffy.jp@gmail.com"]
  spec.homepage    = "https://github.com/DFMCH/dfm_web"
  spec.summary     = "CSS/JS Framework for DFMCH Web Apps"
  spec.description = "CSS/JS Framework for DFMCH Web Apps"
  spec.license     = "MIT"

  spec.files = Dir["{app,config,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"].select do |path|
    File.file?(path) && File.basename(path) != ".DS_Store"
  end


  spec.required_ruby_version = ">= 3.2"
  spec.add_dependency "rails", ">= 8.0"
  spec.add_dependency "nokogiri", ">= 1.15"

  spec.add_development_dependency 'puma'
  spec.add_development_dependency "rspec-rails", "~> 8.0"
end

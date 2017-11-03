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

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  spec.test_files = Dir["spec/**/*"]


  spec.add_dependency "rails", ">= 3.2"           # Tested 3.2, 4.1, 4.2, 5.0
  spec.add_dependency "coffee-rails", ">= 3.2"    # But it should work on 3.2+ with the Asset Pipeline enabled.

  spec.add_development_dependency "rspec-rails", '>= 3.5.0beta3'
  spec.add_development_dependency 'jquery-rails'  # Javascript library.
end

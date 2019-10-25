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


  # Sprockets | Rails | Result
  # 3.7.2     | 5.0.7 | FAIL
  # 3.7.2     | 5.1.7 | OK
  # 3.7.2     | 5.2.3 | OK
  # 3.7.2     | 6.0.0 | OK

  # 4.0.0     | 5.0.7 | FAIL
  # 4.0.0     | 5.1.7 | OK
  # 4.0.0     | 5.2.3 | OK
  # 4.0.0     | 6.0.0 | OK


  spec.add_dependency "rails", ">=5.1"            # Rails 5.1+
  spec.add_dependency 'jquery-rails'              # Jquery

  spec.add_development_dependency 'jquery-tablesorter'
  spec.add_development_dependency "rspec-rails", '>= 3.5.0beta3'
end

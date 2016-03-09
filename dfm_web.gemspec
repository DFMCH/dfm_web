$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dfm_web/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dfm_web"
  s.version     = DfmWeb::VERSION
  s.authors     = ["Jacob Duffy"]
  s.email       = ["duffy.jp@gmail.com"]
  s.homepage    = "http://fammed.wisc.edu"
  s.summary     = "CSS/JS Framework for DFM Web Apps"
  s.description = "CSS/JS Framework for DFM Web Apps"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2"           # Tested 3.2, 4.1, 4.2, 5.0
  s.add_dependency "coffee-rails", ">= 3.2"    # But it should work on 3.2+ with the Asset Pipeline enabled.

  s.add_development_dependency "sqlite3"
end

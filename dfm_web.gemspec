$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "dfm_web/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "dfm_web"
  s.version     = DfmWeb::VERSION
  s.authors     = ["Jacob Duffy"]
  s.email       = ["duffy.jp@gmail.com"]
  s.homepage    = "TODO"
  s.summary     = "CSS/JS Framework for DFM Web Apps"
  s.description = "CSS/JS Framework for DFM Web Apps"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.8"

  s.add_development_dependency "sqlite3"
end

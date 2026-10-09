require_relative "spec_helper"
require_relative "dummy/config/environment"
require "rspec/rails"
require "capybara/rspec"
require "selenium-webdriver"

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.before(:each, type: :system) do
    driven_by :selenium, using: :headless_chrome, screen_size: [1440, 1000]
  end
end
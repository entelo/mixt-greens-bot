require "selenium-webdriver"
require "pry"
require "capybara/dsl"
require "./helpers.rb"
require "dotenv"
Dotenv.load

CAPYBARA_BROWSER_WIDTH = 1024
CAPYBARA_BROWSER_HEIGHT = 768

Capybara.register_driver :selenium_chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.configure do |config|
  config.default_driver = :selenium_chrome
  config.default_max_wait_time = 5
end

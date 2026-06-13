RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless do |driver_options|
      driver_options.add_argument "--no-sandbox"
      driver_options.add_argument "--disable-dev-shm-usage"
      driver_options.add_argument "--headless=new"
    end
  end
end

Capybara.default_host = "http://www.example.com"
Capybara.always_include_port = true

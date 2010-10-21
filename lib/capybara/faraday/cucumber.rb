require 'capybara/faraday'

Before('@faraday') do
  Capybara.current_driver = :faraday
end
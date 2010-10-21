module Capybara
  module Driver
    autoload :Faraday, 'capybara/driver/faraday_driver'
  end
end

Capybara.register_driver :faraday do |app|
  Capybara::Driver::Faraday.new(app)
end
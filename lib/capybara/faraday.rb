module Capybara
  module Driver
    autoload :Faraday, 'capybara/driver/faraday_driver'
  end
end

Capybara.register_driver :faraday do |app|
  Capybara::Driver::Faraday.new(app)
end

Capybara.register_driver :faraday_action_dispatch do |app|
  Capybara::Driver::Faraday.new(app, :adapter => :action_dispatch)
end

Capybara.register_driver :faraday_typhoeus do |app|
  Capybara::Driver::Faraday.new(app, :adapter => :typhoeus)
end

Capybara.register_driver :faraday_patron do |app|
  Capybara::Driver::Faraday.new(app, :adapter => :patron)
end
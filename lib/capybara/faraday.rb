require "capybara"

module Capybara
  module Driver
    autoload :Faraday, 'capybara/driver/faraday_driver'
  end
end

Capybara.register_driver :faraday do |app|
  Capybara::Driver::Faraday.new(app) # Net::HTTP
end

Capybara.register_driver :faraday_excon do |app|
  Capybara::Driver::Faraday.new(app, :adapter => :excon)
end

Capybara.register_driver :faraday_typhoeus do |app|
  Capybara::Driver::Faraday.new(app, :adapter => :typhoeus)
end

Capybara.register_driver :faraday_patron do |app|
  Capybara::Driver::Faraday.new(app, :adapter => :patron)
end

Capybara.register_driver :faraday_em_http do |app|
  Capybara::Driver::Faraday.new(app, :adapter => :em_http)
end

require 'bundler/setup'
require 'capybara'
require 'capybara/restfulie'

require 'sinatra'

require 'capybara/spec/extended_test_app'

# TODO move this stuff into capybara
require 'capybara/spec/driver'
require 'capybara/spec/session'

alias :running :lambda

Capybara.default_wait_time = 0 # less timeout so tests run faster

RSpec.configure do |config|
  config.after do
    Capybara.default_selector = :xpath
  end
end

# You need to add
# 127.0.0.1 capybara-testapp.heroku.com to your hosts file
REMOTE_TEST_HOST = "capybara-testapp.heroku.com"
REMOTE_TEST_PORT = "8070"
REMOTE_TEST_URL = "http://#{REMOTE_TEST_HOST}:#{REMOTE_TEST_PORT}"
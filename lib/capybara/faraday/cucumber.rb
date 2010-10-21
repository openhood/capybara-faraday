require 'capybara/faraday'

Before('@faraday') do
  Capybara.current_driver = :faraday
end

Before('@faraday_action_dispatch') do
  Capybara.current_driver = :faraday_action_dispatch
end

Before('@faraday_typhoeus') do
  Capybara.current_driver = :faraday_typhoeus
end

Before('@faraday_patron') do
  Capybara.current_driver = :faraday_patron
end

require 'capybara/faraday'

Before('@faraday') do
  Capybara.current_driver = :faraday
  page.driver.reset_with!
end

Before('@faraday_excon') do
  Capybara.current_driver = :faraday_excon
  page.driver.reset_with!
end

Before('@faraday_typhoeus') do
  Capybara.current_driver = :faraday_typhoeus
  page.driver.reset_with!
end

Before('@faraday_patron') do
  Capybara.current_driver = :faraday_patron
  page.driver.reset_with!
end

Before('@faraday_em_http') do
  Capybara.current_driver = :faraday_em_http
  page.driver.reset_with!
end

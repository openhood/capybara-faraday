require 'spec_helper'

describe Capybara::Driver::Faraday do
  before(:each) do
    Capybara.server_port = REMOTE_TEST_PORT
    Capybara.app_host = REMOTE_TEST_URL
  end
  
  after(:each) do
    Capybara.server_port = nil
    Capybara.app_host = nil
  end

  before do
    @driver = Capybara::Driver::Faraday.new(TestApp)
  end
  
  context "in remote mode" do
    it_should_behave_like "driver"
    it_should_behave_like "driver with header support"
    it_should_behave_like "driver with status code support"
    # it_should_behave_like "driver with cookies support"
    # it_should_behave_like "driver with infinite redirect detection"
  end
  
end
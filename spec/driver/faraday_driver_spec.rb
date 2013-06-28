require 'spec_helper'

describe Capybara::Driver::Faraday do
  before do
    @driver = described_class.new TestApp
  end

  context "in remote mode" do
    it_should_behave_like "driver"
    it_should_behave_like "driver with header support"
    it_should_behave_like "driver with status code support"
    # neither supports cookies nor follows redirect automatically
  end

  context "basic authentication" do
    subject do
      app = Sinatra.new do
        use Rack::Auth::Basic do |username, password|
          username=="admin" && password=="secret"
        end
        get("/"){ "Success!" }
      end
      described_class.new app
    end

    it "allow access with right credentials" do
      subject.authenticate_with "admin", "secret"
      subject.get "/"
      subject.status_code.should be 200
      subject.source.should == "Success!"
    end

    it "deny access with wrong credentials" do
      subject.authenticate_with "admin", "admin"
      subject.get "/"
      subject.status_code.should be 401
    end
  end

  context "timeout" do
    context "default" do
      subject do
        driver = described_class.new TestApp
      end

      it "is 3 seconds" do
        subject.options[:timeout].should == 3
      end

      it "is used during request" do
        expect do
          subject.get "/slow_response"
        end.to_not raise_error
      end
    end

    context "accepts custom timeout" do
      subject do
        driver = described_class.new TestApp, timeout: 1
      end

      it "is stored in options" do
        subject.options[:timeout].should == 1
      end

      it "is used during request" do
        expect do
          subject.get "/slow_response"
        end.to raise_error Faraday::Error::TimeoutError
      end
    end
  end

end

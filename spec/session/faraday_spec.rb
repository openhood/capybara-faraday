require 'spec_helper'

describe Capybara::Session do
  before(:each) do
    Capybara.server_port = REMOTE_TEST_PORT
    Capybara.app_host = REMOTE_TEST_URL
  end
  
  after(:each) do
    Capybara.server_port = nil
    Capybara.app_host = nil
  end
  
  def extract_results(session)
    YAML.load Nokogiri::HTML(session.body).xpath("//pre[@id='results']").first.text
  end

  after do
    @session.reset!
  end
  
  
  context 'with faraday driver' do
    before do
      @session = Capybara::Session.new(:faraday, TestApp)
    end

    describe '#driver' do
      it "should be a faraday driver" do
        @session.driver.should be_an_instance_of(Capybara::Driver::Faraday)
      end
    end

    describe '#mode' do
      it "should remember the mode" do
        @session.mode.should == :faraday
      end
    end

    # We do not support all session possibilities
    # we only import thoses we should support
    # it_should_behave_like "click_link"
    describe '#click_link' do
      before do
        @session.visit('/with_html')
      end

      context "with id given" do
        it "should take user to the linked page" do
          @session.click_link('foo')
          @session.body.should include('Another World')
        end
      end

      context "with text given" do
        it "should take user to the linked page" do
          @session.click_link('labore')
          @session.body.should include('Bar')
        end

        it "should accept partial matches" do
          @session.click_link('abo')
          @session.body.should include('Bar')
        end

        it "should prefer exact matches over partial matches" do
          @session.click_link('A link')
          @session.body.should include('Bar')
        end
      end

      context "with title given" do
        it "should take user to the linked page" do
          @session.click_link('awesome title')
          @session.body.should include('Bar')
        end

        it "should accept partial matches" do
          @session.click_link('some tit')
          @session.body.should include('Bar')
        end

        it "should prefer exact matches over partial matches" do
          @session.click_link('a fine link')
          @session.body.should include('Bar')
        end
      end

      context "with alternative text given to a contained image" do
        it "should take user to the linked page" do
          @session.click_link('awesome image')
          @session.body.should include('Bar')
        end

        it "should take user to the linked page" do
          @session.click_link('some imag')
          @session.body.should include('Bar')
        end

        it "should prefer exact matches over partial matches" do
          @session.click_link('fine image')
          @session.body.should include('Bar')
        end
      end

      context "with a locator that doesn't exist" do
        it "should raise an error" do
          running do
            @session.click_link('does not exist')
          end.should raise_error(Capybara::ElementNotFound)
        end
      end

      # it "should follow redirects" do
      #   @session.click_link('Redirect')
      #   @session.body.should include('You landed')
      # end

      # it "should follow redirects" do
      #   @session.click_link('BackToMyself')
      #   @session.body.should include('This is a test')
      # end

      # it "should do nothing on anchor links" do
      #   @session.fill_in("test_field", :with => 'blah')
      #   @session.click_link('Anchor')
      #   @session.find_field("test_field").value.should == 'blah'
      #   @session.click_link('Blank Anchor')
      #   @session.find_field("test_field").value.should == 'blah'
      # end

      it "should do nothing on URL+anchor links for the same page" do
        @session.fill_in("test_field", :with => 'blah')
        @session.click_link('Anchor on same page')
        @session.find_field("test_field").value.should == 'blah'
      end

      it "should follow link on URL+anchor links for a different page" do
        @session.click_link('Anchor on different page')
        @session.body.should include('Bar')
      end

      it "raise an error with links with no href" do
        running do
          @session.click_link('No Href')
        end.should raise_error(Capybara::ElementNotFound)
      end
    end
    
    # it_should_behave_like "find_button"
    # it_should_behave_like "find_field"
    # it_should_behave_like "find_link"
    # it_should_behave_like "find_by_id"
    # it_should_behave_like "find"
    describe '#find' do
      before do
        @session.visit('/with_html')
      end

      after do
        Capybara::Selector.remove(:monkey)
      end

      it "should find the first element using the given locator" do
        @session.find('//h1').text.should == 'This is a test'
        @session.find("//input[@id='test_field']")[:value].should == 'monkey'
      end

      it "should be aliased as locate for backward compatibility" do
        Capybara.should_receive(:deprecate).with("locate", "find").twice
        @session.locate('//h1').text.should == 'This is a test'
        @session.locate("//input[@id='test_field']")[:value].should == 'monkey'
      end

      it "should find the first element using the given locator and options" do
        @session.find('//a', :text => 'Redirect')[:id].should == 'red'
        @session.find(:css, 'a', :text => 'A link')[:title].should == 'twas a fine link'
      end

      describe 'the returned node' do
        # it "should act like a session object" do
        #   @session.visit('/form')
        #   @form = @session.find(:css, '#get-form')
        #   @form.should have_field('Middle Name')
        #   @form.should have_no_field('Languages')
        #   @form.fill_in('Middle Name', :with => 'Monkey')
        #   @form.click_button('med')
        #   extract_results(@session)['middle_name'].should == 'Monkey'
        # end

        it "should scope CSS selectors" do
          @session.find(:css, '#second').should have_no_css('h1')
        end
      end

      context "with css selectors" do
        it "should find the first element using the given locator" do
          @session.find(:css, 'h1').text.should == 'This is a test'
          @session.find(:css, "input[id='test_field']")[:value].should == 'monkey'
        end
      end

      context "with id selectors" do
        it "should find the first element using the given locator" do
          @session.find(:id, 'john_monkey').text.should == 'Monkey John'
          @session.find(:id, 'red').text.should == 'Redirect'
          @session.find(:red).text.should == 'Redirect'
        end
      end

      context "with xpath selectors" do
        it "should find the first element using the given locator" do
          @session.find(:xpath, '//h1').text.should == 'This is a test'
          @session.find(:xpath, "//input[@id='test_field']")[:value].should == 'monkey'
        end
      end

      context "with custom selector" do
        it "should use the custom selector" do
          Capybara::Selector.add(:monkey) { |name| ".//*[@id='#{name}_monkey']" }
          @session.find(:monkey, 'john').text.should == 'Monkey John'
          @session.find(:monkey, 'paul').text.should == 'Monkey Paul'
        end
      end

      context "with custom selector with :for option" do
        it "should use the selector when it matches the :for option" do
          Capybara::Selector.add(:monkey, :for => Fixnum) { |num| ".//*[contains(@id, 'monkey')][#{num}]" }
          @session.find(:monkey, '2').text.should == 'Monkey Paul'
          @session.find(1).text.should == 'Monkey John'
          @session.find(2).text.should == 'Monkey Paul'
          @session.find('//h1').text.should == 'This is a test'
        end
      end

      context "with css as default selector" do
        before { Capybara.default_selector = :css }
        it "should find the first element using the given locator" do
          @session.find('h1').text.should == 'This is a test'
          @session.find("input[id='test_field']")[:value].should == 'monkey'
        end
        after { Capybara.default_selector = :xpath }
      end

      it "should raise ElementNotFound with specified fail message if nothing was found" do
        running do
          @session.find(:xpath, '//div[@id="nosuchthing"]', :message => 'arghh').should be_nil
        end.should raise_error(Capybara::ElementNotFound, "arghh")
      end

      it "should raise ElementNotFound with a useful default message if nothing was found" do
        running do
          @session.find(:xpath, '//div[@id="nosuchthing"]').should be_nil
        end.should raise_error(Capybara::ElementNotFound, "Unable to find '//div[@id=\"nosuchthing\"]'")
      end

      it "should accept an XPath instance and respect the order of paths" do
        @session.visit('/form')
        @xpath = XPath::HTML.fillable_field('Name')
        @session.find(@xpath).value.should == 'John Smith'
      end

      context "within a scope" do
        before do
          @session.visit('/with_scope')
        end

        it "should find the first element using the given locator" do
          @session.within(:xpath, "//div[@id='for_bar']") do
            @session.find('.//li').text.should =~ /With Simple HTML/
          end        
        end
      end
    end

    it_should_behave_like "has_content"
    it_should_behave_like "has_css"
    it_should_behave_like "has_css"
    it_should_behave_like "has_selector"
    it_should_behave_like "has_xpath"
    # it_should_behave_like "has_link"
    # it_should_behave_like "has_button"
    # it_should_behave_like "has_field"
    # it_should_behave_like "has_select"
    # it_should_behave_like "has_table"
    # it_should_behave_like "within"
    it_should_behave_like "current_url"

    it_should_behave_like "session without javascript support"
    it_should_behave_like "session with headers support"
    it_should_behave_like "session with status code support"
  end
end
require "faraday"

class Capybara::Driver::Faraday < Capybara::Driver::Base
  class Node < Capybara::Driver::RackTest::Node
    def click
      driver.process(:get, self[:href].to_s) if self[:href].present?
    end
  end

  attr_accessor :as, :follow
  attr_reader :app, :rack_server, :options, :response
  
  def client
    @client ||= Faraday::Connection.new do |con|
      con.adapter :typhoeus
    end
  end
  
  def initialize(app, options={})
    @app = app
    @options = options
    @rack_server = Capybara::Server.new(@app)
    @rack_server.boot if Capybara.run_server
  end

  def visit(url, params = {})
    reset_cache
    process :get, url, params
  end
  
  def get(url, params = {}, headers = {})
    reset_cache
    process :get, url, params, headers
  end

  def post(url, params = {}, headers = {})
    reset_cache
    process :post, url, params, headers
  end

  def put(url, params = {}, headers = {})
    reset_cache
    process :put, url, params, headers
  end

  def delete(url, params = {}, headers = {})
    reset_cache
    process :delete, url, params, headers
  end

  def head(url, params = {}, headers = {})
    reset_cache
    process :head, url, params, headers
  end

  def patch(url, params = {}, headers = {})
    reset_cache
    process :patch, url, params, headers
  end

  def request(url, params = {}, headers = {})
    reset_cache
    process :request, url, params, headers
  end
  
  def submit(method, path, attributes)
    path = request.path if not path or path.empty?
    process method.to_sym, path, attributes
  end

  def find(selector)
    case response.headers["content-type"]
    when "application/xml", "text/xml"
      xml.xpath(selector).map { |node| Node.new(self, node) }
    when "text/html"
      html.xpath(selector).map { |node| Node.new(self, node) }
    else
      raise "Content-Type: #{response.headers["content-type"]} is not handling xpath search"
    end
  end
  
  def html
    @html ||= Nokogiri::HTML(body)
  end
  def xml
    @xml ||= Nokogiri::XML(body)
  end
  def json
    @json ||= ActiveSupport::JSON.decode(body)
  end
  
  def body
    response.body
  end
  alias_method :source, :body
  
  def response_headers
    response.headers["Content-Type"] = response.headers["content-type"]
    response.headers
  end

  def status_code
    response.status
  end
  
  def current_url
    @current_uri.to_s
  end
  
  def reset!
    @client = nil
    @response = nil
    @current_uri = nil
    reset_cache
  end
  
  def as
    @as ||= "application/json"
  end
  
  def with
    @with ||= {}
  end

  def process(method, path, params = {}, headers = {})
    response = client.send(method) do |req|
      if method == :get
        req.url url(path), params
      else
        req.url url(path)
        req.body = params
      end
      req.headers.merge!(headers.merge("Content-Type" => as, "Accept" => as))
    end
    @current_uri = url(path)
    @response = response
  end

  def url(path)
    rack_server.url(path)
  end

private

  def reset_cache
    @xml = nil
    @html = nil
    @json = nil
  end

end
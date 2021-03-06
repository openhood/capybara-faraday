require "faraday"

class Capybara::Driver::Faraday < Capybara::Driver::Base
  class Node < Capybara::RackTest::Node
    def click
      driver.process(:get, self[:href].to_s) if self[:href] && self[:href] != ""
    end
  end

  attr_writer :as, :with_headers, :with_params, :with_options
  attr_reader :app, :adapter, :rack_server, :options, :response, :login, :password

  def client
    @client ||= Faraday::Connection.new{|c| c.adapter adapter}
  end

  def initialize(app, options={})
    @app = app
    @adapter = options.delete(:adapter) || :net_http
    @options = {
      :timeout => 3, # 3 seconds
    }.merge options
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
    dom.xpath(selector).map { |node| Node.new(self, node) }
  end

  def html
    @html ||= Nokogiri::HTML body
  end

  def xml
    @xml ||= Nokogiri::XML body
  end

  def json
    @json ||= Yajl::Parser.parse body
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
    @login = nil
    @password = nil
    reset_cache
  end

  def reset_with!
    @with_headers = {}
    @with_params = {}
    @with_options = {}
  end

  def as
    @as ||= "application/json"
  end

  def with_headers
    @with_headers ||= {}
  end

  def with_params
    @with_params ||= {}
  end

  def with_options
    @with_options ||= {}
  end

  def authenticate_with(login, password)
    @login, @password = login, password
  end

  def auth?
    login && password
  end

  def process(method, path, params = {}, headers = {})
    client.basic_auth login, password if auth?
    response = client.send(method) do |req|
      if method == :get
        req.url url(path), params
      else
        req.url url(path)
        req.body = params
      end
      req.headers.merge!(headers.merge("Content-Type" => as, "Accept" => as))
      req.options = options
    end
    @current_uri = url(path)
    @response = response
  end

  def url(path)
    rack_server.url(path)
  end

  def dom
    content_type = response_headers["Content-Type"]
    case content_type.to_s[/\A[^;]+/]
    when "application/xml", "text/xml"
      xml
    when "text/html"
      html
    else
      raise "Content-Type: #{content_type} is not handling xpath search"
    end
  end

private

  def reset_cache
    @xml = nil
    @html = nil
    @json = nil
  end

end

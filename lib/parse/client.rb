# encoding: utf-8
require 'parse/protocol'
require 'parse/error'
require 'parse/util'

require 'logger'

# This module contains all the code
module Parse
  # The client that communicates with the Parse server via REST
  class Client
    RETRIED_EXCEPTIONS = [
      'Faraday::Error::TimeoutError',
      'Faraday::Error::ParsingError',
      'Faraday::Error::ConnectionFailed',
      'Parse::ParseProtocolRetry'
    ]

    attr_accessor :host
    attr_accessor :path
    attr_accessor :application_id
    attr_accessor :api_key
    attr_accessor :master_key
    attr_accessor :session_token
    attr_accessor :session
    attr_accessor :max_retries
    attr_accessor :logger
    attr_accessor :quiet
    attr_accessor :timeout
    attr_accessor :interval
    attr_accessor :backoff_factor
    attr_accessor :retried_exceptions
    attr_reader :get_method_override

    def initialize(data = {}, &_blk)
      @host           = data[:host]
      @path           = data[:path] || Protocol::PATH

      @application_id = data[:application_id]
      @master_key     = data[:master_key]

      @api_key        = data[:api_key]
      @session_token  = data[:session_token]
      @max_retries    = data[:max_retries] || 3
      @logger         = data[:logger] || Logger
        .new(STDERR).tap { |l| l.level = Logger::INFO }
      @quiet          = data[:quiet] || false
      @timeout        = data[:timeout] || 30

      # Additional parameters for Faraday Request::Retry
      @interval       = data[:interval] || 0.5
      @backoff_factor = data[:backoff_factor] || 2

      @retried_exceptions = RETRIED_EXCEPTIONS
      @retried_exceptions += data[:retried_exceptions] if data[
        :retried_exceptions]

      @get_method_override = data[:get_method_override]

      options = { request: { timeout: @timeout, open_timeout: @timeout } }

      @session = Faraday.new(host, options) do |c|
        c.request :json

        c.use Faraday::GetMethodOverride if @get_method_override

        c.use Faraday::BetterRetry,
              max: @max_retries,
              logger: @logger,
              interval: @interval,
              backoff_factor: @backoff_factor,
              exceptions: @retried_exceptions
        c.use Faraday::ExtendedParseJson

        c.response :logger, @logger unless @quiet

        c.adapter Faraday.default_adapter

        yield(c) if block_given?
      end
    end

    # Perform an HTTP request for the given uri and method
    # with common basic response handling. Will raise a
    # ParseProtocolError if the response has an error status code,
    # and will return the parsed JSON body on success, if there is one.
    def request(uri, method = :get, body = nil, query = nil, content_type = nil)
      headers = {}

      {
        'Content-Type'                  => content_type || 'application/json',
        'User-Agent'                    => "Parse for Ruby, #{VERSION}",
        Protocol::HEADER_MASTER_KEY     => @master_key,
        Protocol::HEADER_APP_ID         => @application_id,
        Protocol::HEADER_API_KEY        => @api_key,
        Protocol::HEADER_SESSION_TOKEN  => @session_token
      }.each do |key, value|
        headers[key] = value if value
      end

      uri = ::File.join(path, uri)
      response = @session.send(method, uri, query || body || {}, headers)
      response.body

    # NOTE: Don't leak our internal libraries to our clients.
    # Extend this list of exceptions as needed.
    rescue Faraday::Error::ClientError => e
      raise Parse::ConnectionError, e.message
    end

    def get(uri)
      request(uri)
    end

    def post(uri, body)
      request(uri, :post, body)
    end

    def put(uri, body)
      request(uri, :put, body)
    end

    def delete(uri)
      request(uri, :delete)
    end

    def application_config
      Parse::Application.config(self)
    end

    def batch
      Parse::Batch.new(self)
    end

    def cloud_function(function_name)
      Parse::Cloud::Function.new(function_name, self)
    end

    def file(data)
      Parse::File.new(data, self)
    end

    def object(class_name, data = nil)
      Parse::Object.new(class_name, data, self)
    end

    def push(data, channel = '')
      Parse::Push.new(data, channel, self)
    end

    def installation(object_id = nil)
      Parse::Installation.new(object_id, self)
    end

    def query(class_name)
      Parse::Query.new(class_name, self)
    end

    def user(data)
      Parse::User.new(data, self)
    end
  end

  # Module methods
  # ------------------------------------------------------------
  class << self
    # Factory to create instances of Client.
    def create(data = {}, &blk)
      options = defaults = {
        application_id: ENV['PARSE_APPLICATION_ID'],
        master_key: ENV['PARSE_MASTER_API_KEY'],
        api_key: ENV['PARSE_REST_API_KEY'],
        get_method_override: true
      }.merge(data)

      Client.new(options, &blk)
    end
    alias :init :create

    # A convenience method for using global.json
    def init_from_cloud_code(path = '../config/global.json', app_name = nil)
      global = JSON.parse(::File.open(path).read)
      applications = global['applications']
      app_name = applications['_default']['link'] if app_name.nil?
      application_id = applications[app_name]['applicationId']
      master_key = applications[app_name]['masterKey']
      create(application_id: application_id, master_key: master_key)
    end

    # Perform a simple retrieval of a simple object, or all objects of a
    # given class. If object_id is supplied, a single object will be
    # retrieved. If object_id is not supplied, then all objects of the
    # given class will be retrieved and returned in an Array.
    # Accepts an explicit client object to avoid using the legacy singleton.
    def get(class_name, object_id = nil, parse_client = nil)
      c = parse_client || client
      data = c.get(Protocol.class_uri(class_name, object_id))
      object = Parse.parse_json(class_name, data)
      object = Parse.copy_client(c, object)
      object
    rescue ParseProtocolError => e
      if e.code == Protocol::ERROR_OBJECT_NOT_FOUND_FOR_GET
        e.message += ": #{class_name}:#{object_id}"
      end
      raise
    end
  end
end

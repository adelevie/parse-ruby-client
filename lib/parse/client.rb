require 'parse/protocol'
require 'parse/error'
require 'parse/util'

require 'logger'
module Parse

  # A class which encapsulates the HTTPS communication with the Parse
  # API server. Currently uses the Patron library for low-level HTTP
  # communication.
  class Client
    attr_accessor :host
    attr_accessor :application_id
    attr_accessor :api_key
    attr_accessor :master_key
    attr_accessor :session_token
    attr_accessor :session
    attr_accessor :max_retries
    attr_accessor :logger

    def initialize(data = {})
      @host           = data[:host] || Protocol::HOST
      @application_id = data[:application_id]
      @api_key        = data[:api_key]
      @master_key     = data[:master_key]
      @session_token  = data[:session_token]
      @max_retries    = data[:max_retries] || 3
      @logger         = data[:logger] || Logger.new(STDERR).tap{|l| l.level = Logger::INFO}

      options = {:request => {:timeout => 30, :open_timeout => 30}}
      @session = Faraday.new "https://#{host}", options do |c|
        c.request :multipart
        c.request :json
        c.response :logger, @logger
        c.use Faraday::BetterRetry,
          max: @max_retries,
          interval: 0.5,
          exceptions: [ 'Faraday::Error::ParsingError', 'Parse::ParseProtocolRetry',
                        'Errno::ETIMEDOUT', 'Timeout::Error', 'Error::TimeoutError' ]
        c.use Faraday::ExtendedParseJson
        c.adapter Faraday.default_adapter
      end
      set_session_headers!
    end

    # Perform an HTTP request for the given uri and method
    # with common basic response handling. Will raise a
    # ParseProtocolError if the response has an error status code,
    # and will return the parsed JSON body on success, if there is one.
    def request(uri, method = :get, body = nil, query = nil, content_type = nil)
      set_session_headers!
      @session.headers['Content-Type'] = content_type || 'application/json'
      @session.send(method, uri, (query || body || {})).body
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

    protected
      def set_session_headers!
        {
          "User-Agent"                    => 'Parse for Ruby, 0.0',
          Protocol::HEADER_MASTER_KEY     => @master_key,
          Protocol::HEADER_APP_ID         => @application_id,
          Protocol::HEADER_API_KEY        => @api_key,
          Protocol::HEADER_SESSION_TOKEN  => @session_token
        }.each do |key, value|
          @session.headers[key] = value if value
        end
      end

      # def log_retry(e, uri, query, body, response)
      #   logger.warn{"Retrying Parse Error #{e.inspect} on request #{uri} #{CGI.unescape(query.inspect)} #{body.inspect} response #{response.inspect}"}
      # end
  end


  # Module methods
  # ------------------------------------------------------------
  class << self
    # A singleton client for use by methods in Object.
    # Always use Parse.client to retrieve the client object.
    @client = nil

    # Initialize the singleton instance of Client which is used
    # by all API methods. Parse.init must be called before saving
    # or retrieving any objects.
    def init(data = {})
      defaults = {:application_id => ENV["PARSE_APPLICATION_ID"], :api_key => ENV["PARSE_REST_API_KEY"]}
      defaults.merge!(data)

      # use less permissive key if both are specified
      defaults[:master_key] = ENV["PARSE_MASTER_API_KEY"] unless data[:master_key] || defaults[:api_key]
      @@client = Client.new(defaults)
    end

    # A convenience method for using global.json
    def init_from_cloud_code(path = "../config/global.json")
      # warning: toplevel constant File referenced by Parse::Object::File
      global = JSON.parse(Object::File.open(path).read)
      application_name  = global["applications"]["_default"]["link"]
      application_id    = global["applications"][application_name]["applicationId"]
      master_key        = global["applications"][application_name]["masterKey"]
      self.init(:application_id => application_id, :master_key => master_key)
    end

    # Used mostly for testing. Lets you delete the api key global vars.
    def destroy
      @@client = nil
      self
    end

    def client
      raise ParseError, "API not initialized" if !@@client
      @@client
    end

    # Perform a simple retrieval of a simple object, or all objects of a
    # given class. If object_id is supplied, a single object will be
    # retrieved. If object_id is not supplied, then all objects of the
    # given class will be retrieved and returned in an Array.
    def get(class_name, object_id = nil)
      data = self.client.get( Protocol.class_uri(class_name, object_id) )
      self.parse_json class_name, data
    rescue ParseProtocolError => e
      if e.code == Protocol::ERROR_OBJECT_NOT_FOUND_FOR_GET
        e.message += ": #{class_name}:#{object_id}"
      end
      raise
    end
  end

end


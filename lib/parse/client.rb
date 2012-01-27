require 'parse/protocol'
require 'parse/error'
require 'parse/util'

module Parse

  # A class which encapsulates the HTTPS communication with the Parse
  # API server. Currently uses the Patron library for low-level HTTP
  # communication.
  class Client
    attr_accessor :host
    attr_accessor :application_id
    attr_accessor :api_key
    attr_accessor :session

    def initialize(data = {})
      @host           = data[:host] || Protocol::HOST
      @application_id = data[:application_id]
      @api_key        = data[:api_key]
      @session        = Patron::Session.new

      @session.base_url                 = "https://#{host}"
      @session.headers["Content-Type"]  = "application/json"
      @session.headers["Accept"]        = "application/json"
      @session.headers["User-Agent"]    = "Parse for Ruby, 0.0"
      @session.headers[Protocol::HEADER_API_KEY]  = @api_key
      @session.headers[Protocol::HEADER_APP_ID]   = @application_id
    end

    # Perform an HTTP request for the given uri and method
    # with common basic response handling. Will raise a
    # ParseProtocolError if the response has an error status code,
    # and will return the parsed JSON body on success, if there is one.
    def request(uri, method = :get, body = nil, query = nil)
      options = {}
      if body
        options[:data] = body
      end
      if query
        options[:query] = query
      end

      response = @session.request(method, uri, {}, options)
      if response.status >= 400
        raise ParseProtocolError, response
      else
        if response.body
          return JSON.parse response.body
        end
      end
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

  end


  # Module methods
  # ------------------------------------------------------------

  # A singleton client for use by methods in Object.
  # Always use Parse.client to retrieve the client object.
  @@client = nil

  # Initialize the singleton instance of Client which is used
  # by all API methods. Parse.init must be called before saving
  # or retrieving any objects.
  def Parse.init(data)
    @@client = Client.new(data)
  end

  def Parse.client
    if !@@client
      raise ParseError, "API not initialized"
    end
    @@client
  end

  # Perform a simple retrieval of a simple object, or all objects of a
  # given class. If object_id is supplied, a single object will be
  # retrieved. If object_id is not supplied, then all objects of the
  # given class will be retrieved and returned in an Array.
  def Parse.get(class_name, object_id = nil)
    data = Parse.client.get( Protocol.class_uri(class_name, object_id) )
    Parse.parse_json class_name, data
  end

end


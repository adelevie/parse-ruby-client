require 'parse/protocol'
require 'parse/error'
require 'parse/util'

require 'iron_mq'

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

    def initialize(data = {})
      @host           = data[:host] || Protocol::HOST
      @application_id = data[:application_id]
      @api_key        = data[:api_key]
      @master_key     = data[:master_key]
      @session_token  = data[:session_token]
      @max_retries    = data[:max_retries] || 3
      @session        = Patron::Session.new
      @session.timeout = 30
      @session.connect_timeout = 30

      if data[:ironio_project_id] && data[:ironio_token]

        if data[:max_concurrent_requests]
          @max_concurrent_requests = data[:max_concurrent_requests]
        else
          @max_concurrent_requests = 50
        end

        @queue = IronMQ::Client.new({
          :project_id => data[:ironio_project_id],
          :token => data[:ironio_token]
        }).queue("concurrent_parse_requests")

      end

      @session.base_url                 = "https://#{host}"
      @session.headers["Content-Type"]  = "application/json"
      @session.headers["Accept"]        = "application/json"
      @session.headers["User-Agent"]    = "Parse for Ruby, 0.0"
    end

    # Perform an HTTP request for the given uri and method
    # with common basic response handling. Will raise a
    # ParseProtocolError if the response has an error status code,
    # and will return the parsed JSON body on success, if there is one.
    def request(uri, method = :get, body = nil, query = nil, content_type = nil)
      @session.headers[Protocol::HEADER_MASTER_KEY]    = @master_key
      @session.headers[Protocol::HEADER_API_KEY]  = @api_key
      @session.headers[Protocol::HEADER_APP_ID]   = @application_id
      @session.headers[Protocol::HEADER_SESSION_TOKEN]   = @session_token

      if content_type
        @session.headers["Content-Type"] = content_type
      end

      options = {}
      if body
        options[:data] = body
      end
      if query
        options[:query] = query
      end

      num_tries = 0
      begin
        num_tries += 1

        if @queue

          #while true
          #  if @queue.reload.size >= @max_concurrent_requests
          #    sleep 1
          #  else
              # add to queue before request
              @queue.post("1")
              response = @session.request(method, uri, {}, options)
              # delete from queue after request
              msg = @queue.get()
              msg.delete
          #  end
          #end
        else
          response = @session.request(method, uri, {}, options)
        end

        parsed = JSON.parse(response.body)

        if response.status >= 400
          raise ParseProtocolError.new(parsed)
        end

        if content_type
          @session.headers["Content-Type"] = "application/json"
        end

        return parsed
      rescue Patron::TimeoutError
        retry if num_tries <= max_retries
        raise
      rescue ParseProtocolError => e
        if num_tries <= max_retries
          sleep 60 if e.code == Protocol::ERROR_EXCEEDED_BURST_LIMIT
          retry if [Protocol::ERROR_EXCEEDED_BURST_LIMIT, Protocol::ERROR_TIMEOUT].include?(e.code)
        end
        raise
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
  def Parse.init(data = {})
    defaulted = {:application_id => ENV["PARSE_APPLICATION_ID"],
                 :api_key => ENV["PARSE_REST_API_KEY"]}
    defaulted.merge!(data)

    # use less permissive key if both are specified
    defaulted[:master_key] = ENV["PARSE_MASTER_API_KEY"] unless data[:master_key] || defaulted[:api_key]


    @@client = Client.new(defaulted)
  end

  # A convenience method for using global.json
  def Parse.init_from_cloud_code(path="../config/global.json")
    global = JSON.parse(Object::File.open(path).read) # warning: toplevel constant File referenced by Parse::Object::File
    application_name = global["applications"]["_default"]["link"]
    application_id = global["applications"][application_name]["applicationId"]
    master_key = global["applications"][application_name]["masterKey"]
    Parse.init :application_id => application_id,
               :master_key     => master_key
  end

  # Used mostly for testing. Lets you delete the api key global vars.
  def Parse.destroy
    @@client = nil
    self
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
  rescue ParseProtocolError => e
    if e.code == Protocol::ERROR_OBJECT_NOT_FOUND_FOR_GET
      e.message += ": #{class_name}:#{object_id}"
    end

    raise
  end

end


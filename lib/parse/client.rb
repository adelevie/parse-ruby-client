require 'parse/protocol'
require 'parse/error'

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

    def get(uri)
      response = @session.get(uri)
      if response.status >= 400
        raise ParseProtocolError, response
      end
      parse_response response
    end

    def parse_response(response)
      if response.body
        data = JSON.parse response.body
        if data.size == 1 && data[Protocol::RESPONSE_KEY_RESULTS]
          data[Protocol::RESPONSE_KEY_RESULTS].collect { |o| Parse::Object.new o}
        else
          Parse::Object.new data
        end
      end
    end
    private :parse_response

  end

  # A singleton client for use by methods in Object
  @@client = nil

  def self.init(data)
    @@client = Client.new(data)
  end

  def self.client
    if !@@client
      raise ParseError, "API not initialized"
    end
    @@client
  end

  # Perform a simple retrieval of a simple object, or all objects of a
  # given class.
  def self.get(class_name, object_id = nil)
    uri = Protocol.class_uri(class_name, object_id)
    response = self.client.session.get(uri)
    if response.status == 200
      data = JSON.parse response.body
      if data.size == 1 && data["results"].is_a?( Array )
        data["results"].collect { |hash| Parse::Object.new class_name, hash }
      else
        Parse::Object.new class_name, data
      end
    end
  end

end


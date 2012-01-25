require 'json'
require 'patron'
require 'date'

# A quick library for playing with parse.com's REST API for object storage.
# See https://parse.com/docs/rest for full documentation on the API.
module Parse

  # A module which encapsulates the specifics of Parse's REST API.
  module Protocol

    # The default hostname for communication with the Parse API.
    HOST            = "api.parse.com"

    # The version of the REST API implemented by this module.
    VERSION         = 1

    # The HTTP header used for passing your application ID to the
    # Parse API.
    HEADER_APP_ID   = "X-Parse-Application-Id"

    # The HTTP header used for passing your API key to the
    # Parse API.
    HEADER_API_KEY  = "X-Parse-REST-API-Key"

    # The JSON key used to store the ID of Parse objects
    # in their JSON representation.
    KEY_OBJECT_ID   = "objectId"

    # The JSON key used to store the creation timestamp of
    # Parse objects in their JSON representation.
    KEY_CREATED_AT  = "createdAt"

    # The JSON key used to store the last modified timestamp
    # of Parse objects in their JSON representation.
    KEY_UPDATED_AT  = "updatedAt"

    # The JSON key used in the top-level response object
    # to indicate that the response contains an array of objects.
    RESPONSE_KEY_RESULTS = "results"

    # Construct a uri referencing a given Parse object
    # class or instance (of object_id is non-nil).
    def self.class_uri(class_name, object_id = nil)
      if object_id
        "/#{VERSION}/classes/#{class_name}/#{object_id}"
      else
        "/#{VERSION}/classes/#{class_name}"
      end
    end

  end

  # Base exception class for errors thrown by the Parse
  # client library. ParseError will be raised by any
  # network operation if Parse.init() has not been called.
  class ParseError < Exception
  end

  # An exception class raised when the REST API returns an error.
  # The error code and message will be parsed out of the HTTP response,
  # which is also included in the response attribute.
  class ParseProtocolError < ParseError
    attr_accessor :code
    attr_accessor :error
    attr_accessor :response

    def initialize(response)
      @response = response
      if response.body
        data = JSON.parse response.body
        @code = data["code"]
        @message = data["error"]
      end
    end
  end

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

  # Represents an individual Parse API object.
  # Methods that interact with the parse.com REST API are named
  # with the prefix parse_ to distinguish them and avoid conflicts
  # (i.e. such as with Hash.delete)
  class Object  < Hash
    attr_reader :parse_object_id
    attr_reader :class_name
    attr_reader :created_at
    attr_reader :updated_at
    attr_reader :acl

    def initialize(class_name, data = nil)
      @class_name = class_name
      if data
        parse data
      end
    end

    def parse(data)
      @parse_object_id = data[Protocol::KEY_OBJECT_ID]
      @created_at      = data[Protocol::KEY_CREATED_AT]
      if @created_at
        @created_at = DateTime.parse @created_at
      end
      @updated_at      = data[Protocol::KEY_UPDATED_AT]
      if @updated_at
        @updated_at = DateTime.parse @updated_at
      end
      self.merge! data
      # Remove the reserved keywords, so they won't be serialized
      # on save'
      self.delete Protocol::KEY_CREATED_AT
      self.delete Protocol::KEY_OBJECT_ID
      self.delete Protocol::KEY_UPDATED_AT
    end
    private :parse

    def parse_save
      uri = Protocol.class_uri @class_name, @parse_object_id
      method = @parse_object_id ? :put : :post
      body = self.to_json
      response = Parse.client.session.request(method, uri, {}, :data => body)
      if response.status >= 200 && response.status <= 300
        if response.body
          data = JSON.parse response.body
          parse data
        end
        if response.status == 201 # Created
          location = response.headers["Location"]
          @parse_object_id = location.split("/").last
        end
      end
      response
    end

    def parse_refresh
      if @parse_object_id
        uri = Protocol.class_uri @class_name, @parse_object_id
        response = Parse.client.session.request(:get, uri, {})
        if response.status == 200
          data = JSON.parse response.body
          parse data
        end
        response
      end
    end

    def parse_delete
      if @parse_object_id
        uri = Protocol.class_uri @class_name, @parse_object_id
        response = parse.client.session.request(:delete, uri, {})
        response
      end
    end
  end

end
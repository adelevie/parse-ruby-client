require 'parse/protocol'
require 'parse/client'
require 'parse/error'
require 'parse/object'

module Parse
  class Installation < Parse::Object

    attr_accessor :device_type
    attr_accessor :installation_id
    attr_accessor :device_token
    attr_accessor :badge
    attr_accessor :time_zone
    attr_accessor :channels

    def self.get(installation_id)
      installation = Installation.new(installation_id)

      if response = Parse.client.request(installation.uri, :get, nil, nil)
        installation.parse Parse.parse_json(nil, response)
      end

      installation       
    end

    def initialize(parse_object_id = nil)
      @parse_object_id = parse_object_id
      @device_type = nil
      @device_token = nil
      @channels = []
    end

    def uri
      Protocol.installations_request_uri @parse_object_id
    end

    def method
      if @parse_object_id
        method = :put
      else
        method = :post
      end
    end

    # Write the current state of the local object to the API.
    # If the object has never been saved before, this will create
    # a new object, otherwise it will update the existing stored object.


    # this method fails unless the deviceType is registered with Apple
    # so I don't know how to write a passing test..JJS
    def save
      body = { :deviceType => @device_type, :deviceToken => @device_token, :channels => @channels }

      if response = Parse.client.request(uri, method, body.to_json, nil)
        # array operations can return mutated view of array which needs to be parsed
        parse Parse.parse_json(nil, response)
      end

      self      
    end

  end
end

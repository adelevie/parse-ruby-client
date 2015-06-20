require 'parse/protocol'
require 'parse/client'
require 'parse/error'
require 'parse/object'

module Parse
  class Installation < Parse::Object
    attr_accessor :client

    UPDATABLE_FIELDS = {
      badge: 'badge',
      channels: 'channels',
      time_zone: 'timeZone',
      device_type: 'deviceType',
      push_type: 'pushType',
      gcm_sender_id: 'GCMSenderId',
      device_token: 'deviceToken',
      channel_uris: 'channelUris',
      app_name: 'appName',
      app_version: 'appVersion',
      parse_version: 'parseVersion',
      app_identifier: 'appIdentifier'
    }

    def initialize(parse_object_id, client = nil)
      @parse_object_id = parse_object_id
      @client = client || Parse.client
    end

    def self.get(parse_object_id, parse_client = nil)
      parse_client ||= Parse.client
      new(parse_object_id, parse_client).get
    end

    def get
      response = client.request(uri, :get, nil, nil)
      parse Parse.parse_json(nil, response) if response
    end

    UPDATABLE_FIELDS.each do |method_name, key|
      define_method "#{method_name}=" do |value|
        self[key] = value
      end
    end

    def uri
      Protocol.installation_uri @parse_object_id
    end

    def save
      client.request uri, method, to_json, nil
    end

    def rest_api_hash
      self
    end

    def method
      @parse_object_id ? :put : :post
    end
  end
end

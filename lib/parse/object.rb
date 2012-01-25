require 'parse/protocol'
require 'parse/client'
require 'parse/error'

module Parse

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

    # Merge a hash parsed from the JSON representation into
    # this instance. This will extract the reserved fields,
    # merge the hash keys, and then insure that the reserved
    # fields do not occur in the underlying hash storage.
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

      # Remove the reserved keys, so they won't be serialized
      # on save'
      self.delete Protocol::KEY_CREATED_AT
      self.delete Protocol::KEY_OBJECT_ID
      self.delete Protocol::KEY_UPDATED_AT
    end
    private :parse

    def parse_save
      uri      = Protocol.class_uri @class_name, @parse_object_id
      method   = @parse_object_id ? :put : :post
      body     = self.to_json

      data = Parse.client.request(uri, method, body)
      if data
        parse data
      end
      self
    end

    def parse_refresh
      if @parse_object_id
        data = Protocol.client.get(@class_name, @parse_object_id)
        if data
          parse data
        end
      self
      end
    end

    def parse_delete
      if @parse_object_id
        uri      = Protocol.class_uri @class_name, @parse_object_id

        response = parse.client.session.request(:delete, uri, {})
        response
      end
      nil
    end
  end

end
require 'parse/protocol'
require 'parse/client'
require 'parse/error'

module Parse

  # Represents an individual Parse API object.
  class Object  < Hash
    attr_reader :parse_object_id
    attr_reader :class_name
    attr_reader :created_at
    attr_reader :updated_at

    def initialize(class_name, data = nil)
      @class_name = class_name
      if data
        parse data
      end
    end

    def uri
      Protocol.class_uri @class_name, @parse_object_id
    end

    # Merge a hash parsed from the JSON representation into
    # this instance. This will extract the reserved fields,
    # merge the hash keys, and then insure that the reserved
    # fields do not occur in the underlying hash storage.
    def parse(data)
      if !data
        return
      end

      @parse_object_id ||= data[Protocol::KEY_OBJECT_ID]

      if data[Protocol::KEY_CREATED_AT]
        @created_at = DateTime.parse data[Protocol::KEY_CREATED_AT]
      end

      if data[Protocol::KEY_UPDATED_AT]
        @updated_at = DateTime.parse data[Protocol::KEY_UPDATED_AT]
      end

      self.merge! data

      # Remove the reserved keys, so they won't be serialized
      # on save'
      self.delete Protocol::KEY_CREATED_AT
      self.delete Protocol::KEY_OBJECT_ID
      self.delete Protocol::KEY_UPDATED_AT
    end
    private :parse

    # Write the current state of the local object to the API.
    # If the object has never been saved before, this will create
    # a new object, otherwise it will update the existing stored object.
    def save
      method   = @parse_object_id ? :put : :post
      body     = self.to_json

      data = Parse.client.request(self.uri, method, body)
      if data
        parse data
      end
      self
    end

    # Update the fields of the local Parse object with the current
    # values from the API.
    def refresh
      if @parse_object_id
        data = Parse.client.get self.uri
        if data
          parse data
        end
      end
      self
    end

    # Delete the remote Parse API object.
    def parse_delete
      if @parse_object_id
        response = Parse.client.delete self.uri
      end
      nil
    end

    # Increment the given field by an amount, which defaults to 1.
    def increment(field, amount = 1)
      value = (self[field] || 0) + amount
      self[field] = value
      if !@parse_object_id
        # TODO - warn that the object must be stored first
        return nil
      end

      if amount != 0
        op = amount > 0 ? Protocol::OP_INCREMENT : Protocol::OP_DECREMENT
        body = "{\"#{field}\": {\"#{Protocol::KEY_OP}\": \"#{op}\", \"#{Protocol::KEY_AMOUNT}\" : #{amount.abs}}}"
        data = Parse.client.request( self.uri, :put, body)
        parse data
      end
      self
    end

    # Decrement the given field by an amount, which defaults to 1.
    # A synonym for increment(field, -amount).
    def decrement(field, amount = 1)
      increment field, -amount
    end

  end

end
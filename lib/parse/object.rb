require 'parse/protocol'
require 'parse/client'
require 'parse/error'

module Parse

  # Represents an individual Parse API object.
  class Object < Hash
    attr_reader :parse_object_id
    attr_reader :class_name
    attr_reader :created_at
    attr_reader :updated_at
    alias :id :parse_object_id

    def initialize(class_name, data = nil)
      @class_name = class_name
      if data
        parse data
      end
    end

    def uri
      Protocol.class_uri @class_name, @parse_object_id
    end

    def pointer
      Parse::Pointer.new(self.merge(Parse::Protocol::KEY_CLASS_NAME => class_name)) unless new?
    end

    # Merge a hash parsed from the JSON representation into
    # this instance. This will extract the reserved fields,
    # merge the hash keys, and then ensure that the reserved
    # fields do not occur in the underlying hash storage.
    def parse(data)
      if !data
        return
      end

      @parse_object_id ||= data[Protocol::KEY_OBJECT_ID]

      if data.has_key? Protocol::KEY_CREATED_AT
        @created_at = DateTime.parse data[Protocol::KEY_CREATED_AT]
      end

      if data.has_key? Protocol::KEY_UPDATED_AT
        @updated_at = DateTime.parse data[Protocol::KEY_UPDATED_AT]
      end

      data.each do |k,v|
        if k.is_a? Symbol
          k = k.to_s
        end
				#if Protocol::RESERVED_KEYS.include? k
        self[k] = v
				#end
      end

      self
    end

    def new?
      self["objectId"].nil?
    end

    private :parse

    # Write the current state of the local object to the API.
    # If the object has never been saved before, this will create
    # a new object, otherwise it will update the existing stored object.
    def save
      method   = @parse_object_id ? :put : :post

      without_reserved = self.dup
      Protocol::RESERVED_KEYS.each { |k| without_reserved.delete(k) }

      without_relations = without_reserved
      without_relations.each { |k,v|
          if v.is_a? Hash
            if v[Protocol::KEY_TYPE] == Protocol::TYPE_RELATION
              without_relations.delete(k)
            end
          end
      }

      body     = without_relations.to_json
      data = Parse.client.request(self.uri, method, body)

      if data
        parse data
      end

      if @class_name == Parse::Protocol::CLASS_USER
        self.delete("password")
        self.delete(:username)
        self.delete(:password)
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

      self.clear
      self
    end

    # Increment the given field by an amount, which defaults to 1.
    def increment(field, amount = 1)
      #value = (self[field] || 0) + amount
      #self[field] = value
      #if !@parse_object_id
      #  # TODO - warn that the object must be stored first
      #  return nil
      #end

      #if amount != 0
      #  op = amount > 0 ? Protocol::OP_INCREMENT : Protocol::OP_DECREMENT
      #  body = "{\"#{field}\": {\"#{Protocol::KEY_OP}\": \"#{op}\", \"#{Protocol::KEY_AMOUNT}\" : #{amount.abs}}}"
      #  data = Parse.client.request( self.uri, :put, body)
      #  parse data
      #end
      #self
      body = {field => Parse::Increment.new(amount)}.to_json
      data = Parse.client.request(self.uri, :put, body)
      parse data
      self
    end

    # Decrement the given field by an amount, which defaults to 1.
    # A synonym for increment(field, -amount).
    def decrement(field, amount = 1)
      #increment field, -amount
      body = {field => Parse::Decrement.new(amount)}.to_json
      data = Parse.client.request(self.uri, :put, body)
      parse data
      self
    end

  end

end
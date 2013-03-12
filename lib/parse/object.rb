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
      @op_fields = {}
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

    # make it easier to deal with the ambiguity of whether you're passed a pointer or object
    def get
      self
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

        if k != Parse::Protocol::KEY_TYPE
          self[k] = v
        end
      end

      self
    end

    def new?
      self["objectId"].nil?
    end

    def safe_hash
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

      without_relations
    end

    def safe_json
      safe_hash.to_json
    end

    private :parse

    # Write the current state of the local object to the API.
    # If the object has never been saved before, this will create
    # a new object, otherwise it will update the existing stored object.
    def save
      if @parse_object_id
        method = :put
        self.merge!(@op_fields) # use operations instead of our own view of the columns
      else
        method = :post
      end

      objects_to_return = self.inject({}) do |memo, (key, value)|
        if value.is_a?(Parse::Object) && value.class_name # parse-ruby-client makes hashes Parse::Object (like the ACL)
          memo[key] = value
          self[key] = value.pointer
        elsif value.is_a?(Array)
          memo[key] = value
          self[key] = value.map do |inner_value|
            if inner_value.is_a?(Parse::Object) && inner_value.class_name
              inner_value.pointer
            else
              inner_value
            end
          end
        end

        memo
      end

      body = safe_json
      data = Parse.client.request(self.uri, method, body)

      if data
        parse data
      end

      objects_to_return.each do |key, value|
        self[key] = value
      end

      if @class_name == Parse::Protocol::CLASS_USER
        self.delete("password")
        self.delete(:username)
        self.delete(:password)
      end

      self
    end

    def as_json(*a)
      Hash[self.map do |key, value|
        value = if value
          value.respond_to?(:as_json) ? value.as_json : value
        else
          Protocol::DELETE_OP
        end

        [key, value]
      end]
    end

    def to_json(*a)
      as_json.to_json(*a)
    end

    def to_s
      "#{@class_name}:#{@parse_object_id} #{super}"
    end

    def inspect
      "#{@class_name}:#{@parse_object_id} #{super}"
    end

    # Update the fields of the local Parse object with the current
    # values from the API.
    def refresh
      if @parse_object_id
        data = Parse.get @class_name, @parse_object_id
        clear
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

    def array_add(field, value)
      array_op(field, Protocol::KEY_ADD, value)
    end

    def array_add_relation(field, value)
      array_op(field, Protocol::KEY_ADD_RELATION, value)
    end

    def array_add_unique(field, value)
      array_op(field, Protocol::KEY_ADD_UNIQUE, value)
    end

    def array_remove(field, value)
      array_op(field, Protocol::KEY_REMOVE, value)
    end

    # Increment the given field by an amount, which defaults to 1. Saves immediately to reflect incremented
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

    # Decrement the given field by an amount, which defaults to 1. Saves immediately to reflect decremented
    # A synonym for increment(field, -amount).
    def decrement(field, amount = 1)
      #increment field, -amount
      body = {field => Parse::Decrement.new(amount)}.to_json
      data = Parse.client.request(self.uri, :put, body)
      parse data
      self
    end

    private

    def array_op(field, operation, value)
      raise "field #{field} not an array" if self[field] && !self[field].is_a?(Array)

      if @parse_object_id
        @op_fields[field] ||= ArrayOp.new(operation, [])
        raise "only one operation type allowed per array #{field}" if @op_fields[field].operation != operation
        @op_fields[field].objects << if value.kind_of?(Parse::Object) && value.class_name
          value.pointer
        else
          value
        end
      end

      # parse doesn't return column values on initial POST creation so we must maintain them ourselves
      case operation
      when Protocol::KEY_ADD
        self[field] ||= []
        self[field] << value
      when Protocol::KEY_ADD_RELATION
        self[field] ||= []
        self[field] << value
      when Protocol::KEY_ADD_UNIQUE
        self[field] ||= []
        self[field] << value unless self[field].include?(value)
      when Protocol::KEY_REMOVE
        self[field].delete(value) if self[field]
      end
    end
  end
end

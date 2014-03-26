# -*- encoding : utf-8 -*-
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

    def eql?(other)
      Parse.object_pointer_equality?(self, other)
    end

    alias == eql?

    def hash
      Parse.object_pointer_hash(self)
    end

    def uri
      Protocol.class_uri @class_name, @parse_object_id
    end

    def pointer
      Parse::Pointer.new(rest_api_hash) unless new?
    end

    # make it easier to deal with the ambiguity of whether you're passed a pointer or object
    def get
      self
    end

    def new?
      self["objectId"].nil?
    end

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

      body = safe_hash.to_json
      data = Parse.client.request(self.uri, method, body)

      if data
        # array operations can return mutated view of array which needs to be parsed
        parse Parse.parse_json(class_name, data)
      end

      if @class_name == Parse::Protocol::CLASS_USER
        self.delete("password")
        self.delete(:username)
        self.delete(:password)
      end

      self
    end

    # representation of object to send on saves
    def safe_hash
      Hash[self.map do |key, value|
        if Protocol::RESERVED_KEYS.include?(key)
          nil
        elsif value.is_a?(Hash) && value[Protocol::KEY_TYPE] == Protocol::TYPE_RELATION
          nil
        elsif value.nil?
          [key, Protocol::DELETE_OP]
        else
          [key, Parse.pointerize_value(value)]
        end
      end.compact]
    end

    # full REST api representation of object
    def rest_api_hash
      self.merge(Parse::Protocol::KEY_CLASS_NAME => class_name)
    end

    # Handle the addition of Array#to_h in Ruby 2.1
    def should_call_to_h?(value)
      value.respond_to?(:to_h) && !value.kind_of?(Array)
    end

    def to_h(*a)
      Hash[rest_api_hash.map do |key, value|
        [key, should_call_to_h?(value) ? value.to_h : value]
      end]
    end
    alias :as_json :to_h
    alias :to_hash :to_h

    def to_json(*a)
      to_h.to_json(*a)
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

      body = {field => Parse::Increment.new(amount)}.to_json
      data = Parse.client.request(self.uri, :put, body)
      parse data
      self
    end

    # Decrement the given field by an amount, which defaults to 1. Saves immediately to reflect decremented
    # A synonym for increment(field, -amount).
    def decrement(field, amount = 1)
      increment(field, -amount)
    end

    private

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

    def array_op(field, operation, value)
      raise "field #{field} not an array" if self[field] && !self[field].is_a?(Array)

      if @parse_object_id
        @op_fields[field] ||= ArrayOp.new(operation, [])
        raise "only one operation type allowed per array #{field}" if @op_fields[field].operation != operation
        @op_fields[field].objects << Parse.pointerize_value(value)
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

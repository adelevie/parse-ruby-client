# -*- encoding : utf-8 -*-
require 'cgi'

module Parse

  class Query
    attr_accessor :where
    attr_accessor :class_name
    attr_accessor :order_by
    attr_accessor :order
    attr_accessor :limit
    attr_accessor :skip
    attr_accessor :count
    attr_accessor :include

    def initialize(cls_name)
      @class_name = cls_name
      @where = {}
      @order = :ascending
      @ors = []
    end

    def add_constraint(field, constraint)
      raise ArgumentError, "cannot add constraint to an $or query" if @ors.size > 0
      current = where[field]
      if current && current.is_a?(Hash) && constraint.is_a?(Hash)
        current.merge! constraint
      else
        where[field] = constraint
      end
    end
    #private :add_constraint

    def includes(class_name)
      @includes = class_name
      self
    end

    def or(query)
      raise ArgumentError, "you must pass an entire #{self.class} to \#or" unless query.is_a?(self.class)
      @ors << query
      self
    end

    def eq(field, value)
      add_constraint field, Parse.pointerize_value(value)
      self
    end

    def not_eq(field, value)
      add_constraint field, { "$ne" => Parse.pointerize_value(value) }
      self
    end

    def regex(field, expression)
      add_constraint field, { "$regex" => expression }
      self
    end

    def less_than(field, value)
      add_constraint field, { "$lt" => Parse.pointerize_value(value) }
      self
    end

    def less_eq(field, value)
      add_constraint field, { "$lte" => Parse.pointerize_value(value) }
      self
    end

    def greater_than(field, value)
      add_constraint field, { "$gt" => Parse.pointerize_value(value) }
      self
    end

    def greater_eq(field, value)
      add_constraint field, { "$gte" => Parse.pointerize_value(value) }
      self
    end

    def value_in(field, values)
      add_constraint field, { "$in" => values.map { |v| Parse.pointerize_value(v) } }
      self
    end

    def value_not_in(field, values)
      add_constraint field, { "$nin" => values.map { |v| Parse.pointerize_value(v) } }
      self
    end

    def related_to(field,value)
      h = {"object" => Parse.pointerize_value(value), "key" => field}
      add_constraint("$relatedTo", h )
    end

    def exists(field, value = true)
      add_constraint field, { "$exists" => value }
      self
    end

    def in_query(field, query=nil)
      query_hash = {Parse::Protocol::KEY_CLASS_NAME => query.class_name, "where" => query.where}
      add_constraint(field, "$inQuery" => query_hash)
      self
    end

    def count
      @count = true
      self
    end

    def where_as_json
      if @ors.size > 0
        {"$or" => [self.where] + @ors.map{|query| query.where_as_json}}
      else
        @where
      end
    end

    def get
      uri   = Protocol.class_uri @class_name
      if @class_name == Parse::Protocol::CLASS_USER
        uri = Protocol.user_uri
      elsif @class_name == Parse::Protocol::CLASS_INSTALLATION
        uri = Protocol.installation_uri
      end
      query = { "where" => where_as_json.to_json }
      set_order(query)
      [:count, :limit, :skip, :include].each {|a| merge_attribute(a, query)}
      Parse.client.logger.info{"Parse query for #{uri} #{query.inspect}"}
      response = Parse.client.request uri, :get, nil, query

      if response.is_a?(Hash) && response.has_key?(Protocol::KEY_RESULTS) && response[Protocol::KEY_RESULTS].is_a?(Array)
        parsed_results = response[Protocol::KEY_RESULTS].map{|o| Parse.parse_json(class_name, o)}
        if response.keys.size == 1
          parsed_results
        else
          response.dup.merge(Protocol::KEY_RESULTS => parsed_results)
        end
      else
        raise ParseError.new("query response not a Hash with #{Protocol::KEY_RESULTS} key: #{response.class} #{response.inspect}")
      end
    end

    private

    def set_order(query)
      return unless @order_by
      order_string = @order_by
      order_string = "-#{order_string}" if @order == :descending
      query.merge!(:order => order_string)
    end

    def merge_attribute(attribute, query, query_field = nil)
      value = self.instance_variable_get("@#{attribute.to_s}")
      return if value.nil?
      query.merge!((query_field || attribute) => value)
    end
  end

end

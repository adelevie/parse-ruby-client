require 'cgi'

module Parse

  class Query
    attr_accessor :where
    attr_accessor :class_name
    attr_accessor :order_by
    attr_accessor :order
    attr_accessor :limit
    attr_accessor :skip

    def initialize(cls_name)
      @class_name = cls_name
      @where = {}
      @order = :ascending
    end

    def add_constraint(field, constraint)
      current = where[field]
      if current && current.is_a?(Hash) && constraint.is_a?(Hash)
        current.merge! constraint
      else
        where[field] = constraint
      end
    end
    #private :add_constraint

    def eq(field, value)
      add_constraint field, value
      self
    end

    def regex(field, expression)
      add_constraint field, { "$regex" => expression }
      self
    end

    def less_than(field, value)
      add_constraint field, { "$lt" => value }
      self
    end

    def less_eq(field, value)
      add_constraint field, { "$lte" => value }
      self
    end

    def greater_than(field, value)
      add_constraint field, { "$gt" => value }
      self
    end

    def greater_eq(field, value)
      add_constraint field, { "$gte" => value }
      self
    end

    def value_in(field, values)
      add_constraint field, { "$in" => values }
      self
    end

    def exists(field, value = true)
      add_constraint field, { "$exists" => value }
      self
    end

    def get
      uri   = Protocol.class_uri @class_name
      query = { "where" => CGI.escape(@where.to_json) }

      response = Parse.client.request uri, :get, nil, query
      Parse.parse_json class_name, response
    end

  end

end
require 'base64'

module Parse

  # Pointer
  # ------------------------------------------------------------

  class Pointer
    attr_accessor :parse_object_id
    attr_accessor :class_name
    alias :id :parse_object_id

    def initialize(data)
      @class_name       = data[Protocol::KEY_CLASS_NAME]
      @parse_object_id  = data[Protocol::KEY_OBJECT_ID]
    end

    # make it easier to deal with the ambiguity of whether you're passed a pointer or object
    def pointer
      self
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        class_name == other.class_name &&
        parse_object_id == other.parse_object_id
    end

    alias == eql?

    def hash
      class_name.hash ^ parse_object_id.hash
    end

    def as_json(*a)
      {
          Protocol::KEY_TYPE        => Protocol::TYPE_POINTER,
          Protocol::KEY_CLASS_NAME  => @class_name,
          Protocol::KEY_OBJECT_ID   => @parse_object_id
      }
    end

    def to_json(*a)
        as_json.to_json(*a)
    end

    # Retrieve the Parse object referenced by this pointer.
    def get
      Parse.get @class_name, @parse_object_id if @parse_object_id
    end

    def to_s
      "#{@class_name}:#{@parse_object_id}:Pointer"
    end
  end

  # Date
  # ------------------------------------------------------------

  class Date
    attr_accessor :value

    def initialize(data)
      if data.is_a? DateTime
        @value = data
      elsif data.is_a? Hash
        @value = DateTime.parse data["iso"]
      elsif data.is_a? String
        @value = DateTime.parse data
      end
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        value == other.value
    end

    alias == eql?

    def hash
      value.hash
    end

    def <=>(other)
      value <=> other.value
    end

    def method_missing(method, *args, &block)
      if value.respond_to?(method)
        value.send(method, *args, &block)
      else
        super(method)
      end
    end

    def respond_to?(method, include_private = false)
      super || value.respond_to?(method, include_private)
    end

    def as_json(*a)
      {
          Protocol::KEY_TYPE => Protocol::TYPE_DATE,
          "iso"              => value.iso8601(3)
      }
    end

    def to_json(*a)
        as_json.to_json(*a)
    end
  end

  # Bytes
  # ------------------------------------------------------------

  class Bytes
    attr_accessor :value

    def initialize(data)
      bytes = data["base64"]
      @value = Base64.decode64(bytes)
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        value == other.value
    end

    alias == eql?

    def hash
      value.hash
    end

    def <=>(other)
      value <=> other.value
    end

    def method_missing(method, *args, &block)
      if value.respond_to?(method)
        value.send(method, *args, &block)
      else
        super(method)
      end
    end

    def respond_to?(method, include_private = false)
      super || value.respond_to?(method, include_private)
    end

    def as_json(*a)
      {
          Protocol::KEY_TYPE => Protocol::TYPE_BYTES,
          "base64" => Base64.encode64(@value)
      }
    end

    def to_json(*a)
        as_json.to_json(*a)
    end
  end

  # Increment and Decrement
  # ------------------------------------------------------------

  class Increment
    # '{"score": {"__op": "Increment", "amount": 1 } }'
    attr_accessor :amount

    def initialize(amount)
      @amount = amount
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        amount == other.amount
    end

    alias == eql?

    def hash
      amount.hash
    end

    def as_json(*a)
      {
          Protocol::KEY_OP => Protocol::KEY_INCREMENT,
          Protocol::KEY_AMOUNT => @amount
      }
    end

    def to_json(*a)
        as_json.to_json(*a)
    end
  end

  class Decrement
    # '{"score": {"__op": "Decrement", "amount": 1 } }'
    attr_accessor :amount

    def initialize(amount)
      @amount = amount
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        amount == other.amount
    end

    alias == eql?

    def hash
      amount.hash
    end

    def as_json(*a)
      {
          Protocol::KEY_OP => Protocol::KEY_DECREMENT,
          Protocol::KEY_AMOUNT => @amount
      }
    end

    def to_json(*a)
        as_json.to_json(*a)
    end
  end

  class ArrayOp
    # '{"myArray": {"__op": "Add", "objects": ["something", "something else"] } }'
    attr_accessor :operation
    attr_accessor :objects

    def initialize(operation, objects)
      @operation = operation
      @objects = objects
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        operation == other.operation &&
        objects == other.objects
    end

    alias == eql?

    def hash
      operation.hash ^ objects.hash
    end

    def as_json(*a)
      {
          Protocol::KEY_OP => operation,
          Protocol::KEY_OBJECTS => @objects
      }
    end

    def to_json(*a)
        as_json.to_json(*a)
    end
  end

  # GeoPoint
  # ------------------------------------------------------------

  class GeoPoint
    # '{"location": {"__type":"GeoPoint", "latitude":40.0, "longitude":-30.0}}'
    attr_accessor :longitude, :latitude

    def initialize(data)
      @longitude = data["longitude"]
      @latitude  = data["latitude"]

      if !@longitude && !@latitude
        @longitude = data[:longitude]
        @latitude  = data[:latitude]
      end
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        longitude == other.longitude &&
        latitude == other.latitude
    end

    alias == eql?

    def hash
      longitude.hash ^ latitude.hash
    end

    def as_json(*a)
      {
          Protocol::KEY_TYPE => Protocol::TYPE_GEOPOINT,
          "latitude" => @latitude,
          "longitude" => @longitude
      }
    end

    def to_json(*a)
        as_json.to_json(*a)
    end

    def to_s
      "(#{latitude}, #{longitude})"
    end
  end

  # File
  # ------------------------------------------------------------

  class File
    # '{"avatar": {"__type":"File", "name":"profile.png", "url"=>"http://files.parse.com/blah/profile.png"}}'
    attr_accessor :name
    attr_accessor :url

    def initialize(data)
      @name = data["name"]
      @url = data["url"]
    end

    def eql?(other)
      self.class.equal?(other.class) &&
        url == other.url
    end

    alias == eql?

    def hash
      url.hash
    end

    def as_json(*a)
      {
          Protocol::KEY_TYPE => Protocol::TYPE_FILE,
          "name" => @name,
          "url" => @url
      }
    end

    def to_json(*a)
        as_json.to_json(*a)
    end
  end


end

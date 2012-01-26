module Parse

  # Pointer
  # ------------------------------------------------------------

  class Pointer
    attr_accessor :parse_object_id
    attr_accessor :class_name

    def initialize(data)
      @class_name       = data[Protocol::KEY_CLASS_NAME]
      @parse_object_id  = data[Protocol::KEY_OBJECT_ID]
    end

    def to_json(*a)
      {
          Protocol::KEY_TYPE        => Protocol::TYPE_POINTER,
          Protocol::KEY_CLASS_NAME  => @class_name,
          Protocol::KEY_OBJECT_ID   => @parse_object_id
      }.to_json(*a)
    end

    # Retrieve the Parse object referenced by this pointer.
    def parse_get
      Parse.get @class_name, @parse_object_id
    end
  end

  # Date
  # ------------------------------------------------------------

  class Date
    attr_accessor :value

    def initialize(data)
      value = DateTime.parse data["iso"]
    end

    def to_json(*a)
      {
          Protocol::KEY_TYPE => Protocol::TYPE_DATE,
          "iso"              => value.iso8601
      }.to_json(*a)
    end
  end

  # Bytes
  # ------------------------------------------------------------

  class Bytes
    attr_accessor :value

    def initialize(data)
      bytes = data["base64"]
      # TODO - decode base64
      value = []
    end

    def to_json(*a)
      {
          Protocol::KEY_TYPE => Protocol::TYPE_BYTES,
          # TODO - encode base64
          "base64" => ""
      }.to_json(*a)
    end
  end

end
# -*- encoding : utf-8 -*-

module Parse
  # Parse a JSON representation into a fully instantiated
  # class. obj can be either a primitive or a Hash of primitives as parsed
  # by JSON.parse
  # @param class_name [Object]
  # @param obj [Object]
  def self.parse_json(class_name, obj)
    if obj.nil?
      nil

    # Array
    elsif obj.is_a? Array
      obj.collect { |o| parse_json(class_name, o) }

    # Hash
    elsif obj.is_a? Hash

      # If it's a datatype hash
      if obj.key?(Protocol::KEY_TYPE)
        parse_datatype obj
      elsif class_name # otherwise it must be a regular object, so deep parse it avoiding re-JSON.parsing raw Strings
        # NOTE: passing '' for client to avoid passing nil to trigger the singleton. It's ugly!
        Parse::Object.new(class_name, Hash[obj.map { |k, v| [k, parse_json(nil, v)] }], '')
      else # plain old hash
        obj
      end

    # primitive
    else
      obj
    end
  end

  def self.parse_datatype(obj)
    type = obj[Protocol::KEY_TYPE]

    case type
    when Protocol::TYPE_POINTER
      Parse::Pointer.new obj
    when Protocol::TYPE_BYTES
      Parse::Bytes.new obj
    when Protocol::TYPE_DATE
      Parse::Date.new obj
    when Protocol::TYPE_GEOPOINT
      Parse::GeoPoint.new obj
    when Protocol::TYPE_FILE
      # NOTE: passing '' for client to avoid passing nil to trigger the singleton. It's ugly!
      Parse::File.new(obj, '')
    when Protocol::TYPE_OBJECT # used for relation queries, e.g. "?include=post"
      # NOTE: passing '' for client to avoid passing nil to trigger the singleton. It's ugly!
      Parse::Object.new(obj[Protocol::KEY_CLASS_NAME], Hash[obj.map { |k, v| [k, parse_json(nil, v)] }], '')
    end
  end

  def self.pointerize_value(obj)
    if obj.is_a?(Parse::Object)
      p = obj.pointer
      fail ArgumentError, "new object used in context requiring pointer #{obj}" unless p
      p
    elsif obj.is_a?(Array)
      obj.map do |v|
        Parse.pointerize_value(v)
      end
    elsif obj.is_a?(Hash)
      Hash[obj.map do |k, v|
        [k, Parse.pointerize_value(v)]
      end]
    else
      obj
    end
  end

  def self.object_pointer_equality?(a, b)
    classes = [Parse::Object, Parse::Pointer]
    return false unless classes.any? { |c| a.is_a?(c) } && classes.any? { |c| b.is_a?(c) }
    return true if a.equal?(b)
    return false if a.new? || b.new?

    a.class_name == b.class_name && a.id == b.id
  end

  def self.object_pointer_hash(v)
    if v.new?
      v.object_id
    else
      v.class_name.hash ^ v.id.hash
    end
  end

  # NOTE: this mess is used to pass along the @client to internal objects
  def self.copy_client(client, parsed_data)
    do_copy = lambda do |object|
      if object.is_a?(Parse::Object)
        object.client = client
        object.each do |_key, value|
          value.client = client if value.is_a?(Parse::Object)
        end
      end
      object
    end

    if parsed_data.is_a?(Array)
      parsed_data.collect(&:do_copy)
    else
      parsed_data = do_copy.call(parsed_data)
    end

    parsed_data
  end
end

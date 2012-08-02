module Parse

  # Parse a JSON representation into a fully instantiated
  # class. obj can be either a string or a Hash as parsed
  # by JSON.parse
  # @param class_name [Object]
  # @param obj [Object]
  def Parse.parse_json(class_name, obj)

    if obj.nil?
      nil

    # Array
    elsif obj.is_a? Array
      obj.collect { |o| parse_json(class_name, o) }

    # Hash
    elsif obj.is_a? Hash

      # If it's a datatype hash
      if obj.has_key?(Protocol::KEY_TYPE)
        parse_datatype obj
      elsif obj.size == 1 && obj.has_key?(Protocol::KEY_RESULTS) && obj[Protocol::KEY_RESULTS].is_a?(Array)
        obj[Protocol::KEY_RESULTS].collect { |o| parse_json(class_name, o) }
      else # otherwise it must be a regular object, so deep parse it avoiding re-JSON.parsing raw Strings
        Parse::Object.new class_name, Hash[obj.map{|k,v| [k, parse_json(nil, v)]}]
      end

    # primitive
    else
      obj
    end
  end

  def Parse.parse_datatype(obj)
    type = obj[Protocol::KEY_TYPE]

    case type
      when Protocol::TYPE_POINTER
        Parse::Pointer.new obj
      when Protocol::TYPE_BYTES
        Parse::Bytes.new obj
      when Protocol::TYPE_DATE
        Parse::Date.new obj
    end
  end
end

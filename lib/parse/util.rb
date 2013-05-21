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
      elsif class_name # otherwise it must be a regular object, so deep parse it avoiding re-JSON.parsing raw Strings
        Parse::Object.new class_name, Hash[obj.map{|k,v| [k, parse_json(nil, v)]}]
      else # plain old hash
        obj
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
      when Protocol::TYPE_GEOPOINT
        Parse::GeoPoint.new obj
      when Protocol::TYPE_FILE
        Parse::File.new obj
      when Protocol::TYPE_OBJECT # used for relation queries, e.g. "?include=post"
        Parse::Object.new obj[Protocol::KEY_CLASS_NAME], Hash[obj.map{|k,v| [k, parse_json(nil, v)]}]
    end
  end

  def Parse.pointerize_value(obj)
    if obj.kind_of?(Parse::Object)
      obj.pointer
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

  def Parse.object_pointer_equality?(a, b)
    classes = [Parse::Object, Parse::Pointer]
    return false unless classes.any? { |c| a.kind_of?(c) } && classes.any? { |c| b.kind_of?(c) }
    return true if a.equal?(b)
    return false if a.new? || b.new?

    a.class_name == b.class_name && a.id == b.id
  end

  def Parse.object_pointer_hash(v)
    if v.new?
      v.object_id
    else
      v.class_name.hash ^ v.id.hash
    end
  end

  def Parse.store_objects_by_pointer(obj, store={})
    if obj.is_a?(Parse::Object) && !obj.new?
      if store[obj.pointer] # don't recurse if you have circular objects
        return store
      end

      store[obj.pointer] = obj
    end

    if obj.is_a?(Array)
      obj.each do |v|
        Parse.store_objects_by_pointer(v, store)
      end
    elsif obj.is_a?(Hash)
      obj.each do |k, v|
        Parse.store_objects_by_pointer(v, store)
      end
    end

    store
  end

  def Parse.restore_objects!(obj, store, already_restored={})
    if already_restored[obj]
      return obj
    end

    already_restored[obj] = true

    if obj.is_a?(Hash) # Parse::Object or Hash, we'll actually modify the object
      obj.each do |k, v|
        obj[k] = Parse.restore_objects!(v, store, already_restored)
      end

      obj
    elsif obj.is_a?(Parse::Pointer) && store[obj]
      store[obj]
    elsif obj.is_a?(Array)
      obj.map do |v|
        Parse.restore_objects!(v, store, already_restored)
      end
    else
      obj
    end
  end
end

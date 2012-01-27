module Parse
  # A module which encapsulates the specifics of Parse's REST API.
  module Protocol

    # Basics
    # ----------------------------------------

    # The default hostname for communication with the Parse API.
    HOST            = "api.parse.com"

    # The version of the REST API implemented by this module.
    VERSION         = 1

    # HTTP Headers
    # ----------------------------------------

    # The HTTP header used for passing your application ID to the
    # Parse API.
    HEADER_APP_ID   = "X-Parse-Application-Id"

    # The HTTP header used for passing your API key to the
    # Parse API.
    HEADER_API_KEY  = "X-Parse-REST-API-Key"

    # JSON Keys
    # ----------------------------------------

    # The JSON key used to store the class name of an object
    # in a Pointer datatype.
    KEY_CLASS_NAME  = "className"

    # The JSON key used to store the ID of Parse objects
    # in their JSON representation.
    KEY_OBJECT_ID   = "objectId"

    # The JSON key used to store the creation timestamp of
    # Parse objects in their JSON representation.
    KEY_CREATED_AT  = "createdAt"

    # The JSON key used to store the last modified timestamp
    # of Parse objects in their JSON representation.
    KEY_UPDATED_AT  = "updatedAt"

    # The JSON key used in the top-level response object
    # to indicate that the response contains an array of objects.
    RESPONSE_KEY_RESULTS = "results"

    # The JSON key used to identify an operator in the increment/decrement
    # API call.
    KEY_OP          = "__op"

    # The JSON key used to identify the datatype of a special value.
    KEY_TYPE        = "__type"

    # The JSON key used to specify the numerical value in the
    # increment/decrement API call.
    KEY_AMOUNT      = "amount"

		RESERVED_KEYS = [ KEY_CLASS_NAME, KEY_CREATED_AT, KEY_OBJECT_ID ]

    # Other Constants
    # ----------------------------------------

    # Operation name for incrementing an objects field value remotely
    OP_INCREMENT    = "Increment"

    # Operation name for decrementing an objects field value remotely
    OP_DECREMENT    = "Decrement"


    # The data type name for special JSON objects representing a reference
    # to another Parse object.
    TYPE_POINTER    = "Pointer"

    # The data type name for special JSON objects containing an array of
    # encoded bytes.
    TYPE_BYTES      = "Bytes"

    # The data type name for special JSON objects representing a date/time.
    TYPE_DATE       = "Date"

    # The data type name for special JSON objects representing a
    # location specified as a latitude/longitude pair.
    TYPE_GEOPOINT   = "GeoPoint"

    # The data type name for special JSON objects representing
    # a file.
    TYPE_FILE       = "File"

    # The class name for User objects, when referenced by a Pointer.
    CLASS_USER      = "_User"

    # URI Helpers
    # ----------------------------------------

    # Construct a uri referencing a given Parse object
    # class or instance (of object_id is non-nil).
    def Protocol.class_uri(class_name, object_id = nil)
      if object_id
        "/#{VERSION}/classes/#{class_name}/#{object_id}"
      else
        "/#{VERSION}/classes/#{class_name}"
      end
    end

    # Construct a uri referencing a given Parse user
    # instance or the users category.
    def Protocol.user_uri(user_id = nil)
      if user_id
        "/#{VERSION}/users/#{user_id}"
      else
        "/#{VERSION}/users"
      end
    end

    # Construct a uri referencing a file stored by the API.
    def Protocol.file_uri(file_name)
      "/#{VERSION}/files/#{file_name}"
    end

  end
end
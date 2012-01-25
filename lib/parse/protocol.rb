  # A module which encapsulates the specifics of Parse's REST API.
  module Protocol

    # The default hostname for communication with the Parse API.
    HOST            = "api.parse.com"

    # The version of the REST API implemented by this module.
    VERSION         = 1

    # The HTTP header used for passing your application ID to the
    # Parse API.
    HEADER_APP_ID   = "X-Parse-Application-Id"

    # The HTTP header used for passing your API key to the
    # Parse API.
    HEADER_API_KEY  = "X-Parse-REST-API-Key"

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

    # Construct a uri referencing a given Parse object
    # class or instance (of object_id is non-nil).
    def self.class_uri(class_name, object_id = nil)
      if object_id
        "/#{VERSION}/classes/#{class_name}/#{object_id}"
      else
        "/#{VERSION}/classes/#{class_name}"
      end
    end

  end

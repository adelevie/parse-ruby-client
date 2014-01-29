require 'parse/protocol'
require 'parse/client'
require 'parse/error'
require 'parse/object'

module Parse
  class Installation < Parse::Object

    def initialize(data = nil)
      super(Parse::Protocol::CLASS_INSTALLATION, data)
    end

    def uri
      Protocol.installation_uri @parse_object_id
    end

  end
end

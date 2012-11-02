require 'parse/protocol'
require 'parse/client'
require 'parse/error'
require 'parse/object'

module Parse
  class User < Parse::Object
    
    def self.authenticate(username, password)
      body = {
        "username" => username,
        "password" => password
      }

      response = Parse.client.request(Parse::Protocol::USER_LOGIN_URI, :get, nil, body)
      
      new(response)
    end

    def self.reset_password(email)
      body = {"email" => email}
      Parse.client.post(Parse::Protocol::PASSWORD_RESET_URI, body)
    end

    def initialize(data = nil)
      data["username"] = data[:username] if data[:username]
      data["password"] = data[:password] if data[:password]
      super(Parse::Protocol::CLASS_USER, data)
    end
    
    def uri
      Protocol.user_uri @parse_object_id
    end
    
  end
end
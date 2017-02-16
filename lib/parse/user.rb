# encoding: utf-8
require 'parse/protocol'
require 'parse/client'
require 'parse/error'
require 'parse/object'

module Parse
  # A Parse User
  # https://parseplatform.github.io/docs/rest/guide/#users
  class User < Parse::Object
    def self.authenticate(username, password, client = nil)
      body = {
        'username' => username,
        'password' => password
      }

      client ||= Parse.client
      response = client.request(
        Parse::Protocol::USER_LOGIN_URI, :get, nil, body)
      client.session_token = response[Parse::Protocol::KEY_USER_SESSION_TOKEN]

      new(response, client)
    end

    def self.reset_password(email, client = nil)
      client ||= Parse.client
      body = { 'email' => email }
      client.post(Parse::Protocol::PASSWORD_RESET_URI, body.to_json)
    end

    def initialize(data = nil, client = nil)
      client ||= Parse.client
      data['username'] = data[:username] if data[:username]
      data['password'] = data[:password] if data[:password]
      super(Parse::Protocol::CLASS_USER, data, client)
    end

    def uri
      Protocol.user_uri @parse_object_id
    end
  end
end

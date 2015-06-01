module Parse
  class Application
    def self.config(client = nil)
      client ||= Parse.client
      client.request(Parse::Protocol.config_uri)['params']
    end
  end
end

require 'json'

module Parse
  class Batch
    attr_reader :requests

    def initialize
      @requests ||= []
    end

    def add_request(request)
      @requests << request
    end

    def run!
      uri = Parse::Protocol.batch_request_uri
      body = {:requests => @requests}.to_json
      Parse.client.request(uri, :post, body)
    end
  end
end
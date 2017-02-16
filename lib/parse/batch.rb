# encoding: utf-8
module Parse
  # Issue batch operations
  # https://parseplatform.github.io/docs/rest/guide/#batch-operations
  class Batch
    attr_reader :requests
    attr_accessor :client

    def initialize(client = nil)
      @client = client || Parse.client
      @requests ||= []
    end

    def add_request(request)
      @requests << request
    end

    def create_object(object)
      method = 'POST'
      path = class_uri(object.class_name)
      body = object.safe_hash
      add_request('method' => method, 'path' => path, 'body' => body)
    end

    def update_object(object)
      method = 'PUT'
      path = class_uri(object.class_name, object.id)
      body = object.safe_hash
      add_request('method' => method, 'path' => path, 'body' => body)
    end

    def delete_object(object)
      add_request(
        'method' => 'DELETE', 'path' => class_uri(object.class_name, object.id))
    end

    def class_uri(*args)
      ::File.join(client.path, Parse::Protocol.class_uri(*args))
    end

    def run!
      uri = Parse::Protocol.batch_request_uri
      body = { requests: @requests }.to_json
      @client.request(uri, :post, body)
    end
  end
end

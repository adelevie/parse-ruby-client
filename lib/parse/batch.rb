require 'json'

module Parse
  class Batch
    attr_reader :requests

    def initialize
      @requests ||= []
    end

    def add_request(request)
      request = request.to_hash if request.is_a?(Parse::Batch::Request)
      @requests << request
    end

    def run!
      uri = Parse::Protocol.batch_request_uri
      body = {:requests => @requests}.to_json
      Parse.client.request(uri, :post, body)
    end

    class Request
      attr_accessor :method
      attr_accessor :path
      attr_accessor :body

      def initialize(params={})
        @method = params[:method] if params[:method]
        @path   = params[:path] if params[:path]
        @body   = params[:body] if params[:body]
      end

      def to_hash
        {"method" => @method, "path" => @path, "body" => @body}
      end
    end
  end

end
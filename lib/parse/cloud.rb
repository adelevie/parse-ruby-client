# encoding: utf-8
module Parse
  module Cloud
    # Call cloud functions
    # https://parseplatform.github.io/docs/cloudcode/guide/
    class Function
      attr_accessor :function_name
      attr_accessor :client

      def initialize(function_name, client = nil)
        @function_name = function_name
        @client = client || Parse.client
      end

      def uri
        Protocol.cloud_function_uri(@function_name)
      end

      def call(params = {})
        response = @client.post(uri, params.to_json)
        result = response['result']
        result
      end
    end
  end
end

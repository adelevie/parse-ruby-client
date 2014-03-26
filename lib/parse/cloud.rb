# -*- encoding : utf-8 -*-
module Parse
  module Cloud

    class Function
      attr_accessor :function_name

      def initialize(function_name)
        @function_name = function_name
      end

      def uri
        Protocol.cloud_function_uri(@function_name)
      end

      def call(params={})
        response = Parse.client.post(self.uri, params.to_json)
        result = response["result"]
        result
      end
    end

  end
end

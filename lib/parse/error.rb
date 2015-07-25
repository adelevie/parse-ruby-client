# -*- encoding : utf-8 -*-
module Parse
  # Base exception class for errors thrown by the Parse
  # client library. ParseError will be raised by any
  # network operation if Parse.init() has not been called.
  class ParseError < StandardError
  end

  class ConnectionError < ParseError
  end

  # An exception class raised when the REST API returns an error.
  # The error code and message will be parsed out of the HTTP response,
  # which is also included in the response attribute.
  class ParseProtocolError < ParseError
    attr_accessor :code
    attr_accessor :error
    attr_accessor :response
    attr_accessor :http_status_code

    def initialize(response)
      @response = response
      if response
        @code   = response['code']
        @error  = response['error']
        @http_status_code = response['http_status_code']
      end

      super("#{@code}: #{@error}")
    end

    def to_s
      @message || super
    end

    attr_writer :message
  end

  class ParseProtocolRetry < ParseProtocolError
  end
end

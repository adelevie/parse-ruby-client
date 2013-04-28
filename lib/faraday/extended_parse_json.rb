module Faraday

  class ExtendedParseJson < FaradayMiddleware::ParseJson

    def process_response(env)
      env[:raw_body] = env[:body] if preserve_raw?(env)
      data = parse(env[:body]) || {}

      if env[:status] >= 400
        array_codes = [
          Parse::Protocol::ERROR_INTERNAL,
          Parse::Protocol::ERROR_TIMEOUT,
          Parse::Protocol::ERROR_EXCEEDED_BURST_LIMIT
        ]
        error_hash = { "error" => "HTTP Status #{env[:status]} Body #{env[:body]}" }.merge(data)
        if data['code'] && array_codes.include?(data['code'])
          sleep 60 if data['code'] == Parse::Protocol::ERROR_EXCEEDED_BURST_LIMIT
          raise exception(env).new(error_hash)
        elsif env[:status] >= 500
          raise exception(env).new(error_hash)
        end
        raise Parse::ParseProtocolError.new(error_hash)
      else
        env[:body] = data
      end
    end

    def exception env
      # decide to retry or not
      (env[:retries].to_i.zero? ? Parse::ParseProtocolError : Parse::ParseProtocolRetry)
    end

  end
end

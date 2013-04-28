module Faraday

  class ExtendedParseJson < FaradayMiddleware::ParseJson

    def process_response(env)
      env[:raw_body] = env[:body] if preserve_raw?(env)
      data = parse(env[:body])
      if env[:status] >= 400
        array_codes = [
          Parse::Protocol::ERROR_INTERNAL,
          Parse::Protocol::ERROR_TIMEOUT,
          Parse::Protocol::ERROR_EXCEEDED_BURST_LIMIT
        ]
        if data['code'] && array_codes.include?(data['code'])
          sleep 60 if data['code'] == Parse::Protocol::ERROR_EXCEEDED_BURST_LIMIT
          raise Parse::ParseProtocolRetry.new error_hash(env, data)
        elsif env[:status] >= 500
          raise Parse::ParseProtocolRetry.new error_hash(env, data)
        end
        raise Parse::ParseProtocolError.new error_hash(env, data)
      else
        env[:body] = parsed
      end
    end

    def error_hash(env, data)
      error = "HTTP Status #{env[:status]} Body #{env[:body]}"
      { "error" => error }.merge(data)
    end

  end
end

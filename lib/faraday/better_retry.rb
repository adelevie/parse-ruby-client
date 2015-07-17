module Faraday
  # Custom version of Request::Retry with two additions:
  #    1 - logs (on warn level) each retry attempt
  #    2 - stores in 'X-ParseRubyClient-Retries' header the number of
  #        remaining retries. Used in ExtendedParseJson middleware
  class BetterRetry < Request::Retry
    def initialize(app, options = nil)
      @logger = options.delete(:logger) if options

      super(app, options)

      # NOTE: Faraday 0.9.1 by default does not retry on POST requests
      @options.methods << :post

      # NOTE: the default exceptions are lost when custom ones are given
      @options.exceptions.concat([
        Errno::ETIMEDOUT,
        'Timeout::Error',
        Error::TimeoutError
      ])
    end

    def call(env)
      retries = @options.max
      retries_header(env, retries)
      request_body = env[:body]
      begin
        # after failure env[:body] is set to the response body
        env[:body] = request_body
        @app.call(env)
      rescue @errmatch => exception
        if retries > 0 && retry_request?(env, exception)
          log(env, exception)
          retries -= 1
          retries_header(env, retries)
          sleep sleep_amount(retries + 1)
          retry
        end
        raise
      end
    end

    private

    def log(env, exception)
      msg = "Retrying Parse Error #{exception.inspect} on request #{env[:url]} #{env[:body].inspect} response #{env[:response].inspect}"
      @logger.warn(msg) if @logger
    end

    def retries_header(env, retries)
      # NOTE: env is a Struct object in Faraday now and it gets
      #   instantiated ex-novo on each request so there is no way
      #   to monkey patch it, we have to use a header
      env.request_headers['X-ParseRubyClient-Retries'] = retries.to_s
    end
  end
end

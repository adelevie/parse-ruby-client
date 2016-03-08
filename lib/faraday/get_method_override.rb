# encoding: utf-8
require 'faraday'

module Faraday
  # Public: Writes the original HTTP method to "X-Http-Method-Override" header
  # and sends the request as POST for GET requests that are too long.
  class GetMethodOverride < Faraday::Middleware
    HEADER = 'X-Http-Method-Override'.freeze

    # Public: Initialize the middleware.
    #
    # app     - the Faraday app to wrap
    def initialize(app, _options = nil)
      super(app)
    end

    def call(env)
      if env[:method] == :get && env[:url].to_s.size > 2000
        env[:request_headers][HEADER] = 'GET'
        env[:request_headers]['Content-Type'] =
          'application/x-www-form-urlencoded'
        env[:body] = env[:url].query
        env[:url].query = nil
        env[:method] = :post
      end

      @app.call(env)
    end
  end
end

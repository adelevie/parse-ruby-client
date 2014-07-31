# -*- encoding : utf-8 -*-
require 'helper'

module Middleware
  class ExtedParseJsonTest < Faraday::TestCase

    def conn(retry_options = {})
      Faraday.new do |b|
        b.use Faraday::ExtendedParseJson
        b.adapter :test do |stub|
          stub.get('/invalid_json')     { [200, {}, 'something'] }
          stub.get('/valid_json')       { [200, {}, {'var' => 1}.to_json] }
          stub.get('/parse_error_code') { [403, {}, {'code' => Parse::Protocol::ERROR_INTERNAL}.to_json] }
          stub.get('/empty_response')   { [403, {}, ''] }
          stub.get('/404')              { [404, {}, {}.to_json] }
          stub.get('/500')              { [500, {}, {'text' => 'Internal Server Error'}.to_json] }
        end
      end
    end

    def test_invalid_json
      assert_raise(Faraday::Error::ParsingError) { conn.get("/invalid_json") }
    end

    def test_valid_json
      resp = conn.get("/valid_json")
      assert_equal 200, resp.status
      assert_equal ({'var' => 1}), resp.body
    end

    def test_empty_response
      ex = assert_raise(Parse::ParseProtocolError) { conn.get("/empty_response") }
      assert_match /403/, ex.to_s
      assert_equal "HTTP Status 403 Body ", ex.error
    end

    def test_parse_error_code
      ex = assert_raise(Parse::ParseProtocolError) { conn.get("/parse_error_code") }
      assert_match /403/, ex.to_s
      assert_equal Parse::Protocol::ERROR_INTERNAL, ex.code
    end

    def test_404
      ex = assert_raise(Parse::ParseProtocolError) { conn.get("/404") }
      assert_match /404/, ex.to_s
    end

    def test_500
      ex = assert_raise(Parse::ParseProtocolError) { conn.get("/500") }
      assert_match /500/, ex.to_s
      assert_match /Internal Server Error/, ex.to_s
    end

  end
end

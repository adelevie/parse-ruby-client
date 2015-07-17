require 'helper'
require 'stringio'

module Middleware
  class BetterRetryTest < Faraday::TestCase
    def setup
      @times_called = 0
      @logger_buffer = StringIO.new
      @logger = Logger.new(@logger_buffer).tap { |l| l.level = Logger::WARN }
    end

    def conn(retry_options = {})
      default_options = {
        logger: @logger,
        exceptions: [
          'Faraday::Error::TimeoutError',
          'Faraday::Error::ParsingError',
          'Parse::ParseProtocolRetry'
        ]
      }
      retry_options = default_options.merge(retry_options)

      Faraday.new do |b|
        b.use Faraday::BetterRetry, retry_options
        b.adapter :test do |stub|
          stub.post('/unstable') do
            @times_called += 1
            @explode.call @times_called
          end
        end
      end
    end

    def test_logging_retries
      @explode = ->(_n) { fail Parse::ParseProtocolRetry, 'boom!' }
      assert_raises(Parse::ParseProtocolRetry) { conn.post('/unstable') }
      refute_empty @logger_buffer.string
    end

    def test_retries_header
      @explode = ->(_n) {}
      resp = conn(max: 3).post('/unstable')
      assert_equal '3', resp.env.request_headers['X-ParseRubyClient-Retries']
    end

    def test_unhandled_exception
      @explode = ->(_n) { fail 'boom!' }
      assert_raises(RuntimeError) { conn.post('/unstable') }
      assert_equal 1, @times_called
    end

    def test_default_exception
      @explode = ->(_n) { fail Errno::ETIMEDOUT }
      assert_raises(Errno::ETIMEDOUT) { conn.post('/unstable') }
      assert_equal 3, @times_called
    end
  end
end

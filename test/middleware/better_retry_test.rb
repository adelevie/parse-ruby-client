# -*- encoding : utf-8 -*-
require 'helper'

module Middleware
  class BeterRetryTest < Faraday::TestCase
    def setup
      @times_called = 0
    end

    def conn(retry_options = {})
      Faraday.new do |b|
        b.use Faraday::BetterRetry, retry_options
        b.adapter :test do |stub|
          stub.post('/unstable') {
            @times_called += 1
            @explode.call @times_called
          }
        end
      end
    end

    def test_unhandled_error
      @explode = lambda {|n| raise "boom!" }
      assert_raise(RuntimeError) { conn.post("/unstable") }
      assert_equal 1, @times_called
    end

    def test_handled_error
      @explode = lambda {|n| raise Errno::ETIMEDOUT }
      assert_raise(Errno::ETIMEDOUT) { conn.post("/unstable") }
      assert_equal 3, @times_called
    end

    def test_new_max_retries
      @explode = lambda {|n| raise Errno::ETIMEDOUT }
      assert_raise(Errno::ETIMEDOUT) { conn(:max => 3).post("/unstable") }
      assert_equal 4, @times_called
    end

    def test_interval
      @explode = lambda {|n| raise Errno::ETIMEDOUT }
      started  = Time.now
      assert_raise(Errno::ETIMEDOUT) {
        conn(:max => 2, :interval => 0.1).post("/unstable")
      }
      assert_in_delta 0.2, Time.now - started, 0.03
    end

    def test_custom_exceptions
      @explode = lambda {|n| raise "boom!" }
      assert_raise(RuntimeError) {
        conn(:exceptions => StandardError).post("/unstable")
      }
      assert_equal 3, @times_called
    end
  end
end

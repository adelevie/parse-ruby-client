# -*- encoding : utf-8 -*-
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
end if ENV['COVERAGE']

# minitest
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest/focus'

# mocha + minitest
require 'minitest/unit'
require 'mocha/mini_test'

require 'vcr'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'parse-ruby-client'

unless RUBY_VERSION[0..2] == '2.2'
  YAML::ENGINE.yamler = 'syck' # get ascii strings as strings in fixtures
end

VCR.configure do |c|
  c.cassette_library_dir = 'test/fixtures/vcr_cassettes'
  c.default_cassette_options = { record: :once }
  c.hook_into :webmock # or :fakeweb
  c.filter_sensitive_data('<COOKIE-KEY>') do |i|
    [i.response.headers['Set-Cookie']].flatten.compact.first
  end

  def filter_sensitive_header(c, header)
    c.filter_sensitive_data("<#{header}>") do |interaction|
      v = interaction.request.headers.detect { |k, _| k.casecmp(header) == 0 }
      v.last.first if v
    end
  end

  filter_sensitive_header(c, Parse::Protocol::HEADER_APP_ID)
  filter_sensitive_header(c, Parse::Protocol::HEADER_API_KEY)
  filter_sensitive_header(c, Parse::Protocol::HEADER_MASTER_KEY)
  filter_sensitive_header(c, Parse::Protocol::HEADER_SESSION_TOKEN)
end

class ParseTestCase < Minitest::Test
  def setup
    logger = Logger.new(STDERR).tap { |l| l.level = Logger::ERROR }
    @client = Parse.create(logger: logger)
  end
end

module Faraday
  module LiveServerConfig
    def live_server=(value)
      @@live_server = case value
                      when /^http/
                        URI(value)
                      when /./
                        URI('http://127.0.0.1:4567')
      end
    end

    def live_server?
      defined? @@live_server
    end

    # Returns an object that responds to `host` and `port`.
    def live_server
      live_server? && @@live_server
    end
  end

  class TestCase < Minitest::Test
    extend LiveServerConfig
    self.live_server = ENV['LIVE']

    def test_default
      assert true
    end unless defined? ::MiniTest

    def capture_warnings
      old, $stderr = $stderr, StringIO.new
      begin
        yield
        $stderr.string
      ensure
        $stderr = old
      end
    end

    def self.jruby?
      defined? RUBY_ENGINE && 'jruby' == RUBY_ENGINE
    end

    def self.rbx?
      defined? RUBY_ENGINE && 'rbx' == RUBY_ENGINE
    end

    def self.ssl_mode?
      ENV['SSL'] == 'yes'
    end
  end
end

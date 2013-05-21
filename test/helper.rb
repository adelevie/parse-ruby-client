require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end if ENV["COVERAGE"]

require 'test/unit'
require 'shoulda'
require 'mocha'
require 'vcr'
require 'webmock/test_unit'

require 'simplecov'
SimpleCov.start if ENV['COVERAGE']

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'parse-ruby-client'

YAML::ENGINE.yamler='syck' # get ascii strings as strings in fixtures

VCR.configure do |c|
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  c.allow_http_connections_when_no_cassette = true
  c.filter_sensitive_data("<COOKIE-KEY>") { |i| [i.response.headers['Set-Cookie']].flatten.compact.first }

  def filter_sensitive_header(c, header)
    c.filter_sensitive_data("<#{header}>") do |interaction|
      if v = interaction.request.headers.detect{|k,_| k.casecmp(header) == 0}
        v.last.first
      end
    end
  end

  filter_sensitive_header(c, Parse::Protocol::HEADER_APP_ID)
  filter_sensitive_header(c, Parse::Protocol::HEADER_API_KEY)
  filter_sensitive_header(c, Parse::Protocol::HEADER_MASTER_KEY)
  filter_sensitive_header(c, Parse::Protocol::HEADER_SESSION_TOKEN)
end

class ParseTestCase < Test::Unit::TestCase
  def setup
    @client = Parse.init(:logger => Logger.new(STDERR).tap{|l| l.level = Logger::ERROR})
  end
end
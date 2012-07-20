require 'helper'

class TestPush < Test::Unit::TestCase

  def setup
    Parse.init
  end

  def test_save
    data = {:foo => 'bar',
            :alert => 'message'}
    pf_push = Parse::Push.new(data, "some_chan")
    pf_push.type = 'ios'

    query = Parse::Query.new(Parse::Protocol::CLASS_INSTALLATION).eq('deviceToken', 'baz')
    pf_push.where = query.where

    Parse::Client.any_instance.expects(:request).with do |uri, method, body, query|
      hash = JSON.parse(body)
      assert_equal :post, method
      assert has_entries('type' => 'ios', 'channel' => "some_chan").matches?([hash])
      assert has_entries('foo' => 'bar', 'alert' => 'message').matches?([hash['data']])
      assert has_entries('deviceToken' => 'baz').matches?([hash['where']])
      assert_nil query
      true
    end.returns({}.to_json)

    pf_push.save
  end


end

require 'helper'

class TestPush < ParseTestCase
  def test_initialize_with_only_data
    data = { alert: 'foobar' }
    push = @client.push(data)

    assert_equal data, push.data
    assert push.where.empty?
    assert_raises(NoMethodError) do
      push.channel
    end
  end

  def test_initialize_with_data_and_channel
    data = { alert: 'foobar' }
    push = @client.push(data, 'foobar')

    assert_equal data, push.data
    assert_nil push.where
    assert_equal ['foobar'], push.channels
  end

  def test_push_save_with_type_without_channels_without_where
    push = @client.push(alert: 'foobar')
    push.type = 'ios'

    Parse::Client.any_instance.expects(:request).with do |uri, method, body, q|
      assert_equal Parse::Protocol.push_uri, uri
      assert_equal :post, method
      assert_nil q

      body = JSON.parse(body)
      expected_result = {
        'data' => { 'alert' => 'foobar' },
        'where' => { 'deviceType' => 'ios' }
      }
      assert_equal expected_result, body

      true
    end.returns({}.to_json)

    push.save
  end

  def test_push_save_with_type_and_channels_without_where
    push = @client.push({ alert: 'foobar' }, 'foobar')
    push.type = 'ios'

    Parse::Client.any_instance.expects(:request).with do |uri, method, body, q|
      assert_equal Parse::Protocol.push_uri, uri
      assert_equal :post, method
      assert_nil q

      body = JSON.parse(body)
      expected_result = {
        'data' => { 'alert' => 'foobar' },
        'deviceType' => 'ios',
        'channels' => ['foobar']
      }
      assert_equal expected_result, body

      true
    end.returns({}.to_json)

    push.save
  end

  def test_push_save_with_type_without_channels_with_where
    push = @client.push(alert: 'foobar')
    push.type = 'ios'
    push.where = { appName: 'Test' }

    Parse::Client.any_instance.expects(:request).with do |uri, method, body, q|
      assert_equal Parse::Protocol.push_uri, uri
      assert_equal :post, method
      assert_nil q

      body = JSON.parse(body)
      expected_result = {
        'data' => { 'alert' => 'foobar' },
        'where' => { 'deviceType' => 'ios', 'appName' => 'Test' }
      }
      assert_equal expected_result, body

      true
    end.returns({}.to_json)

    push.save
  end

  def test_push_save_without_type_with_channels_with_where
    push = @client.push(alert: 'foobar')
    push.channels = ['foobar']
    push.where = { appName: 'Test' }

    Parse::Client.any_instance.expects(:request).with do |uri, method, body, q|
      assert_equal Parse::Protocol.push_uri, uri
      assert_equal :post, method
      assert_nil q

      body = JSON.parse(body)
      expected_result = {
        'data' => { 'alert' => 'foobar' },
        'where' => { 'channels' => ['foobar'], 'appName' => 'Test' }
      }
      assert_equal expected_result, body

      true
    end.returns({}.to_json)

    push.save
  end

  def test_push_save_only_with_channels
    push = @client.push(alert: 'foobar')
    push.channels = %w(abcdef bcdefg)

    Parse::Client.any_instance.expects(:request).with do |uri, method, body, q|
      assert_equal Parse::Protocol.push_uri, uri
      assert_equal :post, method
      assert_nil q

      body = JSON.parse(body)
      expected_result = {
        'data' => { 'alert' => 'foobar' },
        'where' => { 'channels' => %w(abcdef bcdefg) }
      }
      assert_equal expected_result, body

      true
    end.returns({}.to_json)

    push.save
  end

  def test_push_save_only_with_where
    push = @client.push(alert: 'foobar')
    push.where = { appName: 'Test' }

    Parse::Client.any_instance.expects(:request).with do |uri, method, body, q|
      assert_equal Parse::Protocol.push_uri, uri
      assert_equal :post, method
      assert_nil q

      body = JSON.parse(body)
      expected_result = {
        'data' => { 'alert' => 'foobar' },
        'where' => { 'appName' => 'Test' }
      }
      assert_equal expected_result, body

      true
    end.returns({}.to_json)

    push.save
  end

  def test_push_save_with_push_time
    push = @client.push(alert: 'foobar')
    push.push_time = Time.at(0).iso8601

    Parse::Client.any_instance.expects(:request).with do |uri, method, body, q|
      assert_equal Parse::Protocol.push_uri, uri
      assert_equal :post, method
      assert_nil q

      body = JSON.parse(body)
      expected_result = {
        'data' => { 'alert' => 'foobar' },
        'where' => {},
        'push_time' => push.push_time
      }
      assert_equal expected_result, body

      true
    end.returns({}.to_json)

    push.save
  end

  def test_push_with_channel_and_type
    VCR.use_cassette('test_push_with_channel_and_type') do
      data = { alert: 'This is a notification from Parse' }
      push = @client.push(data, 'Giants')
      push.type = 'ios'
      result = push.save
      assert result['result']
    end
  end
end

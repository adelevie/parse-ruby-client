# encoding: utf-8
require 'helper'

class TestInstallation < ParseTestCase
  def test_create_installation_with_valid_data
    VCR.use_cassette('test_create_valid_installation') do
      installation = @client.installation.tap do |i|
        i.device_token = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdex'
        i.device_type = 'ios'
      end.save

      assert installation['createdAt']
      assert installation['objectId']
    end
  end

  def test_retrieving_installation_data
    VCR.use_cassette('test_installation_get') do
      installation = Parse::Installation.new(nil, @client).tap do |inst|
        inst['deviceType'] = 'ios'
        inst['deviceToken'] = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
      end.save

      installation_data = Parse::Installation.get(installation['objectId'], @client)
      assert_equal installation_data['objectId'], installation['objectId']
    end
  end

  def test_changing_channels
    installation = Parse::Installation.new('987', @client)
    installation.channels = ['', 'my-channel']
    assert_equal ['', 'my-channel'], installation['channels']
  end

  def test_changing_badges
    installation = Parse::Installation.new('987', @client)
    installation.badge = 5
    assert_equal 5, installation['badge']
  end

  def test_updating_installation_data
    VCR.use_cassette('test_installation_update') do
      installation = Parse::Installation.new(nil, @client).tap do |inst|
        inst['deviceType'] = 'ios'
        inst['deviceToken'] = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
      end
      response = installation.save

      installation.channels = ['', 'my-channel']
      installation.badge = 5
      update_response = installation.save

      assert update_response['updatedAt'] > response['createdAt']

      installation_data = Parse::Installation.get(response['objectId'], @client)
      assert_equal 5, installation_data['badge']
      assert_equal ['', 'my-channel'], installation_data['channels']
    end
  end
end

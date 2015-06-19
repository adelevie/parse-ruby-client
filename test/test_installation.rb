require 'helper'

class TestInstallation < ParseTestCase
  def test_create_installation_with_valid_data
    VCR.use_cassette('test_create_valid_installation') do
      installation = @client.installation.tap do |i|
        i.device_token = '0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef'
        i.device_type = 'ios'
      end.save

      assert_equal installation['createdAt'].class, String
      assert_equal installation['objectId'].class, String
    end
  end

  def test_create_installation_with_invalid_data
    VCR.use_cassette('test_create_invalid_installation') do
      installation = @client.installation.tap do |i|
        i.device_token = '123'
        i.device_type = 'ios'
      end

      assert_raises(Parse::ParseProtocolError) { installation.save }
    end
  end

  def test_retrieving_installation_data
    installation_data = {
      "appIdentifier"=>"net.project_name",
      "appName"=>"Parse Project",
      "appVersion"=>"35",
      "badge"=>9,
      "channels"=>["", "channel1"],
      "deviceToken"=> "123",
      "deviceType"=>"ios",
      "installationId"=>"345",
      "parseVersion"=>"1.3.0",
      "timeZone"=>"Europe/Chisinau",
      "createdAt"=>"2014-09-18T15:04:18.602Z",
      "updatedAt"=>"2014-09-19T12:17:48.509Z",
      "objectId"=>"987"
    }

    VCR.use_cassette('test_get_installation') do
      data = Parse::Installation.get('987', @client)
      assert_equal installation_data, data
    end
  end

  def test_changing_channels
    installation = Parse::Installation.new('987', @client)
    installation.channels = ["", "my-channel"]
    assert_equal ["", "my-channel"], installation["channels"]
  end

  def test_changing_badges
    installation = Parse::Installation.new('987', @client)
    installation.badge = 5
    assert_equal 5, installation["badge"]
  end

  def test_updating_installation_data
    installation = Parse::Installation.new('987', @client)
    installation.channels = ["", "my-channel"]
    installation.badge = 5

    VCR.use_cassette('test_save_installation') do
      result = installation.save
      assert_not_empty result["updatedAt"]
    end
  end
end

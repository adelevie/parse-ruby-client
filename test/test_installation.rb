require 'helper'

class TestInstallation < ParseTestCase
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
      installation = Parse::Installation.get "987"
      assert_equal installation_data, installation
    end
  end
end

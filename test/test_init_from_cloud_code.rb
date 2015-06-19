require 'helper'

class TestInitFromCloudCode < ParseTestCase
  def test_init
    client = Parse.init_from_cloud_code('test/config/global.json')
    assert client.is_a?(Parse::Client)
  end
end

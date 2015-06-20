require 'helper'

class TestApplication < ParseTestCase
  def test_config
    VCR.use_cassette('test_application_config') do
      assert Parse::Application.config(@client)
    end
  end
end

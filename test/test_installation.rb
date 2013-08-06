require 'helper'

class TestModelObject < Parse::Installation
end

class TestInstallation < ParseTestCase

  def test_new
    VCR.use_cassette('test_new_installation', :record => :new_episodes) do
      tmo = TestModelObject.new
      assert_equal tmo.new?, true
      tmo.save
      assert_equal tmo.new?, false
    end
  end

  # this test fails as the device_token isn't understood by Apple
  def test_save
    VCR.use_cassette('test_new_installation', :record => :new_episodes) do
      tmo = TestModelObject.new
      installation = TestModelObject.new
      installation.device_type = 'ios'
      installation.device_token = 'yaba_daba_do'
      installation.channels = ['bambam', 'joe rockhead']
      installation.save

      assert_equal installation.new?, false
    end
  end

  def test_get
    VCR.use_cassette('test_get_installation', :record => :new_episodes) do
      installation = TestModelObject.new
      installation.device_type = 'ios'
      installation.device_token = 'yaba_daba_do'
      installation.channels = ['bambam', 'joe rockhead']
      installation.save

      i = TestModelObject.get(installation.id)

      assert_equal i.id, installation.id
      assert_equal i["device_type"], installation["device_type"]
      assert_equal i["device_token"], installation["device_token"]
      assert_equal i["channels"], installation["channels"]            
    end
  end
end

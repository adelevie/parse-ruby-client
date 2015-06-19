require 'helper'

class TestUser < ParseTestCase
  def test_user_save
    VCR.use_cassette('test_user_save') do
      username = rand.to_s
      data = {
        username: username,
        password: 'topsecret'
      }
      user = Parse::User.new(data, @client)
      user.save
      assert_equal user[Parse::Protocol::KEY_OBJECT_ID].class, String
      assert_equal user[Parse::Protocol::KEY_CREATED_AT].class, String
    end
  end

  def test_user_login
    VCR.use_cassette('test_user_login') do
      data = { username: 'alan299652018572', password: 'secret' }
      user = Parse::User.authenticate(data[:username], data[:password], @client)

      assert_equal data[:username], user['username']
      assert user['sessionToken'].is_a?(String)

      # test pointer
      user = user.pointer.get(@client)
      assert user.save
    end
  end

  def test_reset_password
    VCR.use_cassette('test_user_reset_password') do
      u =  'alan' + rand(10_000_000_000_000).to_s + '@gmail.com'
      data = {
        username: u,
        password: 'secret'
      }

      user = Parse::User.new(data, @client)
      assert user.save

      reset_password = Parse::User.reset_password(u,  @client)

      assert_equal({}, reset_password)
    end
  end
end

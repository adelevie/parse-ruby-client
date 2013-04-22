require 'helper'

class TestUser < ParseTestCase

  def test_user_save
    VCR.use_cassette('test_user_save', :record => :new_episodes) do
      username = rand.to_s
      data = {
        :username => username,
        :password => "topsecret"
      }
      user = Parse::User.new data
      user.save
      assert_equal user[Parse::Protocol::KEY_OBJECT_ID].class, String
      assert_equal user[Parse::Protocol::KEY_CREATED_AT].class, String
    end
  end

  def test_user_login
    #VCR.use_cassette('test_user_login', :record => :new_episodes) do
      u = "alan" + rand(10000000000000).to_s
      data = {
        :username => u,
        :password => "secret"
      }

      user = Parse::User.new(data)

      user.save

      assert_equal user["username"], u
      assert_equal user[Parse::Protocol::KEY_USER_SESSION_TOKEN].class, String

      login = Parse::User.authenticate(u, "secret")

      assert_equal login["username"], user["username"]
      assert_equal login["sessionToken"].class, String

      user = user.pointer.get
      user.save
    #end
  end

  def test_reset_password
    u =  "alan" + rand(10000000000000).to_s + "@gmail.com"
    data = {
      :username => u,
      :password => "secret"
    }

    user = Parse::User.new(data)

    user.save

    reset_password = Parse::User.reset_password(u)

    assert_equal Hash.new, reset_password
  end

end

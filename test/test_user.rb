require 'helper'

class TestUser < Test::Unit::TestCase
  
  def setup
    Parse.init
  end

  def test_save
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
  
  def test_login
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
    
    #assert_equal login["username"], "alan123"
    #assert_equal login["sessionToken"].class, String
  end

end

require 'helper'

class TestClient < Test::Unit::TestCase
  def setup
    @client = Parse.init
  end

  def test_request
    VCR.use_cassette('test_request', :record => :new_episodes) do
      response = mock()
      response.stubs(:body).returns({'code' => Parse::Protocol::ERROR_TIMEOUT}.to_json)
      response.stubs(:status).returns(400)
      @client.session.expects(:request).times(@client.max_retries + 1).returns(response)
      assert_raise do
       @client.request(nil)
      end
    end
  end

  def test_simple_save
    VCR.use_cassette('test_simple_save', :record => :new_episodes) do
      test_save = Parse::Object.new "TestSave"
      test_save["foo"] = "bar"
      test_save.save

      assert_equal test_save["foo"], "bar"
      assert_equal test_save[Parse::Protocol::KEY_CREATED_AT].class, String
      assert_equal test_save[Parse::Protocol::KEY_OBJECT_ID].class, String
    end
  end

  def test_update
    VCR.use_cassette('test_update', :record => :new_episodes) do
      foo = Parse::Object.new "TestSave"
      foo["age"] = 20
      foo.save

      assert_equal foo["age"], 20
      assert_equal foo[Parse::Protocol::KEY_UPDATED_AT], nil

      foo["age"] = 40
      orig = foo.dup
      foo.save

      assert_equal foo["age"], 40
      assert_equal foo[Parse::Protocol::KEY_UPDATED_AT].class, String

      # only difference should be updatedAt
      orig_assoc = orig.reject{|k,v| k == Parse::Protocol::KEY_UPDATED_AT}.to_a
      foo_assoc = foo.reject{|k,v| k == Parse::Protocol::KEY_UPDATED_AT}.to_a
      assert_equal foo_assoc, orig_assoc
    end
  end

  def test_server_update
    VCR.use_cassette('test_server_update', :record => :new_episodes) do
      foo = Parse::Object.new("TestSave").save
      foo["name"] = 'john'
      foo.save

      bar = Parse.get("TestSave",foo.id) # pull it from the server
      assert_equal bar["name"], 'john'
      bar["name"] = 'dave'
      bar.save

      bat = Parse.get("TestSave",foo.id)
      assert_equal bat["name"], 'dave'
    end
  end

  def test_destroy
    VCR.use_cassette('test_destroy', :record => :new_episodes) do
      d = Parse::Object.new "toBeDeleted"
      d["foo"] = "bar"
      d.save
      d.parse_delete

      assert_equal d.keys.length, 0
    end
  end

  def test_get_missing
    VCR.use_cassette('test_get_missing', :record => :new_episodes) do
      e = assert_raise(Parse::ParseProtocolError) { Parse.get("SomeClass", "someIdThatDoesNotExist") }
      assert_equal "101: object not found for get: SomeClass:someIdThatDoesNotExist", e.message
    end
  end
end

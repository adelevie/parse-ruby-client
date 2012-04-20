require 'helper'

class TestClient < Test::Unit::TestCase
  def setup
    Parse.init
  end
  
  def test_simple_save
    test_save = Parse::Object.new "TestSave"
    test_save["foo"] = "bar"
    test_save.save

    assert_equal test_save["foo"], "bar"
    assert_equal test_save[Parse::Protocol::KEY_CREATED_AT].class, String
    assert_equal test_save[Parse::Protocol::KEY_OBJECT_ID].class, String
  end
  
  def test_update
    foo = Parse::Object.new "TestSave"
    foo["age"] = 20
    foo.save
    
    assert_equal foo["age"], 20
    assert_equal foo[Parse::Protocol::KEY_UPDATED_AT], nil
    
    foo["age"] = 40
    foo.save
    
    assert_equal foo["age"], 40
    assert_equal foo[Parse::Protocol::KEY_UPDATED_AT].class, String
  end
  
  def test_server_update
    foo = Parse::Object.new("TestSave").save 
    foo["name"] = 'john'
    foo.save
    
    bar = Parse.get("TestSave",foo.id) # pull it from the server
    assert_equal bar["name"], 'john'
    bar["name"] = 'dave'
    bar.save
    
    bat = Parse.get("TestSave",foo.id)
    assert_equal bar["name"], 'dave'
  end
  
  def test_destroy
    d = Parse::Object.new "toBeDeleted"
    d["foo"] = "bar"
    d.save
    d.parse_delete
    
    assert_equal d.keys.length, 0
  end
end

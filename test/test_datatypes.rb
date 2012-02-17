require 'helper'

class TestDatatypes < Test::Unit::TestCase
  def test_pointer
    data = {
      Parse::Protocol::KEY_CLASS_NAME => "DatatypeTestClass",
      Parse::Protocol::KEY_OBJECT_ID => "12345abcd"
    }
    p = Parse::Pointer.new data
    
    assert_equal p.to_json, "{\"__type\":\"Pointer\",\"#{Parse::Protocol::KEY_CLASS_NAME}\":\"DatatypeTestClass\",\"#{Parse::Protocol::KEY_OBJECT_ID}\":\"12345abcd\"}" 
  end
  
  def test_date
    date_time = DateTime.now
    data = date_time
    parse_date = Parse::Date.new data
    
    assert_equal parse_date.value, date_time
    assert_equal JSON.parse(parse_date.to_json)["iso"], date_time.iso8601
  end
  
  def test_bytes
    data = {
      "base64" => Base64.encode64("testing bytes!")
    }
    byte = Parse::Bytes.new data

    assert_equal byte.value, "testing bytes!"
    assert_equal JSON.parse(byte.to_json)[Parse::Protocol::KEY_TYPE], Parse::Protocol::TYPE_BYTES
    assert_equal JSON.parse(byte.to_json)["base64"], Base64.encode64("testing bytes!")
  end
  
  def test_increment
    amount = 5
    increment = Parse::Increment.new amount
    
    assert_equal increment.to_json, "{\"__op\":\"Increment\",\"amount\":#{amount}}"
  end
  
  def test_decrement
    amount = 5
    increment = Parse::Decrement.new amount
    
    assert_equal increment.to_json, "{\"__op\":\"Decrement\",\"amount\":#{amount}}"
  end
  
  def test_geopoint
    # '{"location": {"__type":"GeoPoint", "latitude":40.0, "longitude":-30.0}}'
    data = {
      "longitude" => 40.0,
      "latitude" => -30.0
    }
    gp = Parse::GeoPoint.new data
    
    assert_equal JSON.parse(gp.to_json)["longitude"], data["longitude"] 
    assert_equal JSON.parse(gp.to_json)["latitude"], data["latitude"]
    assert_equal JSON.parse(gp.to_json)[Parse::Protocol::KEY_TYPE], Parse::Protocol::TYPE_GEOPOINT
  end
end

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
    assert_equal JSON.parse(parse_date.to_json)["iso"], date_time.iso8601(3)
    assert_equal 0, parse_date <=> parse_date
    assert_equal 0, Parse::Date.new(data) <=> Parse::Date.new(data)

    post = Parse::Object.new("Post")
    post["time"] = parse_date
    post.save
    q = Parse.get("Post", post.id)

    # time zone from parse is utc so string formats don't compare equal,
    # also floating points vary a bit so only equality after rounding to millis is guaranteed
    assert_equal parse_date.to_time.utc.to_datetime.iso8601(3), q["time"].to_time.utc.to_datetime.iso8601(3)
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

    post = Parse::Object.new("Post")
    post["location"] = gp
    post.save
    q = Parse.get("Post", post.id)
    assert_equal gp, q["location"]
  end


  # deprecating -  see test_file.rb for new implementation
  # ----------------------------
  #def test_file
  #  data = {"name" => "test/parsers.png"}
  #  file = Parse::File.new(data)
    # assert_equal JSON.parse(file.to_json)["name"], data["name"]
    # assert_equal JSON.parse(file.to_json)[Parse::Protocol::KEY_TYPE], Parse::Protocol::TYPE_FILE

  #  post = Parse::Object.new("Post")
  #  post["avatar"] = file
  #  post.save
  #  q = Parse.get("Post", post.id)
  #  assert_equal file.parse_filename, q["avatar"].parse_filename
  #end
end

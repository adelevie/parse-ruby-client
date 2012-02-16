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
end

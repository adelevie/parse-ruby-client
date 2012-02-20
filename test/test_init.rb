require 'helper'

#Parse.init :application_id => $PARSE_APPLICATION_ID, :api_key => $PARSE_REST_API_KEY

class TestInit < Test::Unit::TestCase
  def setup
    Parse.destroy
  end
  
  def test_no_api_keys_error
    fake = Parse::Object.new "shouldNeverExist"
    fake["foo"] = "bar"
    
    begin
      fake.save
    rescue
      error_triggered = true
    end
    
    assert_equal error_triggered, true
    assert_equal fake[Parse::Protocol::KEY_OBJECT_ID], nil
  end
end

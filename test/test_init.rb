require 'helper'

class TestInit < ParseTestCase
  def setup
    Parse.destroy
  end

  def test_no_api_keys_error
    assert_raises(Parse::ParseError) do
      fake = Parse::Object.new('shouldNeverExist', nil, nil)
      fake['foo'] = 'bar'
      fake.save
    end
  end
end

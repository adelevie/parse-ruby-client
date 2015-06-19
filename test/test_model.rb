require 'helper'

class TestModelObject < Parse::Model
end

class TestModel < ParseTestCase
  def test_new
    VCR.use_cassette('test_model_new') do
      model = TestModelObject.new(nil, @client)
      assert_equal model.new?, true

      model.save
      assert_equal model.new?, false
    end
  end

  def test_superclass
    model = TestModelObject.new(nil, @client)
    assert model.is_a?(Parse::Model)
    assert model.is_a?(Parse::Object)
  end

  def test_find
    VCR.use_cassette('test_model_find') do
      model = TestModelObject.new(nil, @client)
      model.save

      assert TestModelObject.find(model['objectId'], @client)
    end
  end
end

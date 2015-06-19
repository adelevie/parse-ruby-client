require 'helper'

class TestCloud < ParseTestCase
  # functions stored in test/cloud_functions/MyCloudCode
  # see https://parse.com/docs/cloud_code_guide to learn how to use Parse Cloud Code
  #
  # Parse.Cloud.define('trivial', function(request, response) {
  #   response.success(request.params);
  # });

  def test_cloud_function_initialize
    cloud_function = Parse::Cloud::Function.new('trivial', @client)
    assert cloud_function.function_name == 'trivial'
  end

  def test_cloud_function_uri
    assert Parse::Cloud::Function.new('trivial', @client).uri
  end

  def test_cloud_function_call
    skip('this should automate the parse deploy command by committing that binary to the repo')

    VCR.use_cassette('test_cloud_function_call') do
      function = Parse::Cloud::Function.new('trivial', @client)
      params = { 'foo' => 'bar' }
      resp = function.call(params)
      assert_equal resp, params
    end
  end
end

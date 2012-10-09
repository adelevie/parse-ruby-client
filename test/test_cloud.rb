require 'helper'

Parse.init

class TestCloud < Test::Unit::TestCase
	# functions stored in test/cloud_functions/MyCloudCode
	# see https://parse.com/docs/cloud_code_guide to learn how to use Parse Cloud Code
	#
	# Parse.Cloud.define('trivial', function(request, response) {
  # 	response.success(request.params);
	# });

	def setup
    Parse.init
	end

	def test_cloud_function_initialize
		assert_not_equal nil, Parse::Cloud::Function.new("trivial")
	end

	def test_cloud_function
		function = Parse::Cloud::Function.new("trivial")
		params = {}
		resp = function.call(params)
		assert_equal resp, params
	end
end
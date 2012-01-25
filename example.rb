require "awesome_print"

Parse.init :application_id  => "your_application_id",
           :api_key         => "your_api_key"

test_object = Parse::Object.new "TestObject"
test_object["foo"] = "bar"
test_object["bar"] = "foo"
test_object["array"] = [10,11,12,13]
test_object["hash"] = {"thing" => true, "other-thing" => false}
test_object["count"] = 10

rsp = test_object.parse_save
ap rsp

rsp = Parse.get "TestObject"
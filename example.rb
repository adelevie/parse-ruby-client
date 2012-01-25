require "awesome_print"

Parse.init :application_id  => "your_application_id",
           :api_key         => "your_api_key"

profile = Parse::Object.new "Profile"
profile["first_name"]    = "John"
profile["last_name"]     = "Doe"
profile["username"]      = "jdoe"
profile["email_address"] = "jdoe@blahblahblah"

profile.parse_save

profile.parse_refresh

profile.parse_object_id

profile.created_at

profile.parse_increment "login_count", -2

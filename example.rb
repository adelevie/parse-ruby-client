require "awesome_print"

Parse.init :application_id  => "your_application_id",
           :api_key         => "your_api_key"

profile = Parse::Object.new "Profile"
profile["first_name"]    = "John"
profile["last_name"]     = "Doe"
profile["username"]      = "jdoe"
profile["email_address"] = "jdoe@blahblahblah"

profile.save

profile.refresh

profile.parse_object_id

profile.created_at

profile.increment "login_count", -2


# Queries
(1..100).each { |i|
  score = Parse::Object.new "Score"
  score["score"] = i
  score.save
}

q = Parse::Query.new("Score")   \
  .greater_eq("score", 10)  \
  .less_eq("score", 20)

q.get

q = Parse::Query.new("Score") \
  .value_in("score", [10, 20, 30, 40])

q.get


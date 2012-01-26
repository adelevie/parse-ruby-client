# Ruby Client for parse.com REST API

This file implements a simple Ruby client library for using Parse's REST API.
Rather than try to implement an ActiveRecord-compatible library, it tries to
match the structure of the iOS and Android SDKs from Parse.

So far it supports simple GET, PUT, and POST operations on objects. Enough
to read & write simple data.

## Dependencies

This currently depends on the gems 'json' and 'patron' for JSON support and HTTP, respectively.

## Getting Started

To get started, load the parse.rb file and call Parse.init to initialize the client object with
your application ID and API key values, which you can obtain from the parse.com dashboard.

```ruby
Parse.init :application_id => "<your_app_id>",
           :api_key        => "<your_api_key>"

obj = Parse::Object.new "MyClass"
obj["IsFrob"]    = true
obj["FrobCount"] = 10
obj["FrobName"]  = "Framistat"

obj.save
```

### Queries

Queries are supported by the Parse::Query class.

```ruby
# Create some simple objects to query
(1..100).each { |i|
  score = Parse::Object.new "Score"
  score["score"] = i
  score.save
}

# Retrieve all scores between 10 & 20 inclusive
Parse::Query.new("Score")   \
  .greater_eq("score", 10)  \
  .less_eq("score", 20)     \
  .get

# Retrieve a set of specific scores
q = Parse::Query.new("Score")           \
  .value_in("score", [10, 20, 30, 40])  \
  .get

```

## TODO

- Add some form of debug logging
- Support for Date, Pointer, and Bytes API [data types](https://www.parse.com/docs/rest#objects-types)
- Users
- ACLs
- Login


## Resources

[parse.com REST API documentation](https://parse.com/docs/rest)

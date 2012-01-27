# Ruby Client for parse.com REST API

This file implements a simple Ruby client library for using Parse's REST API.
Rather than try to implement an ActiveRecord-compatible library, it tries to
match the structure of the iOS and Android SDKs from Parse.

So far it supports simple GET, PUT, and POST operations on objects. Enough
to read & write simple data.

## Dependencies

This currently depends on the gems 'json' and 'patron' for JSON support and HTTP, respectively.

# Getting Started

---

To get started, load the parse.rb file and call Parse.init to initialize the client object with
your application ID and API key values, which you can obtain from the parse.com dashboard.

```ruby
Parse.init :application_id => "<your_app_id>",
           :api_key        => "<your_api_key>"
```

## Creating and Saving Objects

Create an instance of Parse::Object with your class name supplied as a string, set some keys, and call save().

```ruby
game_score = Parse::Object.new "GameScore"
game_score["score"] 		= 1337
game_score["playerName"]	= "Sean Plott"
game_score["cheatMode"] 	= false
game_score.save
```

Alternatively, you can initialize the object's initial values with a hash.

```ruby
game_score = Parse::Object.new "GameScore", {
	"score" => 1337, "playerName" => "Sean Plott", "cheatMode" => false
}
```

Or if you prefer, you can use symbols for the hash keys - they will be converted to strings
by Parse::Object.initialize().

```ruby
game_score = Parse::Object.new "GameScore", {
		:score => 1337, :playerName => "Sean Plott", :cheatMode => false
}
```

## Retrieving Objects

Individual objects can be retrieved with a single call to Parse.get() supplying the class and object id.

```ruby
game_score = Parse.get "GameScore", "xWMyZ4YEGZ"
```

All the objects in a given class can be retrieved by omitting the object ID. Use caution if you have lots
and lots of objects of that class though.

```ruby
all_scores = Parse.get "GameScore"
```

## Queries

Queries are supported by the ```Parse::Query``` class.

```ruby
# Create some simple objects to query
(1..100).each { |i|
  score = Parse::Object.new "GameScore"
  score["score"] = i
  score.save
}

# Retrieve all scores between 10 & 20 inclusive
Parse::Query.new("GameScore")   \
  .greater_eq("score", 10)      \
  .less_eq("score", 20)         \
  .get

# Retrieve a set of specific scores
Parse::Query.new("GameScore")           \
  .value_in("score", [10, 20, 30, 40])  \
  .get

```

## TODO

- Add some form of debug logging
- ~~Support for Date, Pointer, and Bytes API [data types](https://www.parse.com/docs/rest#objects-types)~~
- Users
- ACLs
- Login


## Resources

- parse.com [REST API documentation](https://parse.com/docs/rest)
- [parse_resource]https://github.com/adelevie/parse_resource , an ActiveRecord-compatible wrapper
  for the API for seamless integration into Rails.

**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [Ruby Client for parse.com REST API](#ruby-client-for-parsecom-rest-api)
  - [Dependencies](#dependencies)
- [Getting Started](#getting-started)
  - [Installation](#installation)
    - [Load API keys from `global.json` created by Cloud Code](#load-api-keys-from-globaljson-created-by-cloud-code)
  - [Creating and Saving Objects](#creating-and-saving-objects)
    - [ActiveRecord-style Models](#activerecord-style-models)
  - [Retrieving Objects](#retrieving-objects)
  - [Queries](#queries)
- [Create some simple objects to query](#create-some-simple-objects-to-query)
- [Retrieve all scores between 10 & 20 inclusive](#retrieve-all-scores-between-10-&-20-inclusive)
- [Retrieve a set of specific scores](#retrieve-a-set-of-specific-scores)
    - [Relational Data](#relational-data)
  - [Push Notifications](#push-notifications)
  - [Batch Requests](#batch-requests)
  - [Cloud Code](#cloud-code)
- [assumes you have a function named "trivial"](#assumes-you-have-a-function-named-"trivial")
- [TODO](#todo)
- [Resources](#resources)
  - [](#)

## Warning

There is an undocumented feature I've been working on, where if you provide IronMQ API keys, you will get a rate-limited rest client. This feature is broken and you should not provide such keys and/or use such a feature until this warning is removed. The feature only existed in 0.1.13 and has been removed in 0.1.14. If you don't provide the keys when calling Parse.init, you will be fine. I'm posting this out of extra caution.

# Ruby Client for parse.com REST API

This file implements a simple Ruby client library for using Parse's REST API.
Rather than try to implement an ActiveRecord-compatible library, it tries to
match the structure of the iOS and Android SDKs from Parse.

So far it supports simple GET, PUT, and POST operations on objects. Enough
to read & write simple data.

## Dependencies

This currently depends on the gems 'json' and 'patron' for JSON support and HTTP, respectively.

# Getting Started

## Installation

[![Gem Version](https://badge.fury.io/rb/parse-ruby-client.png)](http://badge.fury.io/rb/parse-ruby-client)

`gem "parse-ruby-client"`

---

To get started, load the parse.rb file and call Parse.init to initialize the client object with
your application ID and API key values, which you can obtain from the parse.com dashboard.

```ruby
require 'parse-ruby-client'

Parse.init :application_id => "<your_app_id>",
           :api_key        => "<your_api_key>"
```

If you don't like pasting this stuff in every time you fire up irb, save your api keys to `.bash_profile` or similar:

```bash
export PARSE_APPLICATION_ID="12345678"
export PARSE_REST_API_KEY="ABCDEFGH"
```

Now you can just do this:

```ruby
Parse.init
```

The test folder assumes this naming convention for environment variables, so if you want to run the tests, you *must* do this. But it's easy. And good for you, too.

### Load API keys from `global.json` created by Cloud Code

```ruby
Parse.init_from_cloud_code("path/to/global.json")
```

The path defaults to `"../config/global.json"`. So if you create a folder inside the root of a Cloud Code directory, and in that folder is a `.rb` file, just call `Parse.init_from_cloud_code` with no arguments and you're set.

With `Parse::init_from_cloud_code`, you can easily write Ruby [tests for Cloud Code functions](https://github.com/adelevie/ParseCloudTest). 

## Creating and Saving Objects

Create an instance of ```Parse::Object``` with your class name supplied as a string, set some keys, and call ```save()```.

```ruby
game_score = Parse::Object.new "GameScore"
game_score["score"]     = 1337
game_score["playerName"]  = "Sean Plott"
game_score["cheatMode"]   = false
game_score.save
```

Alternatively, you can initialize the object's initial values with a hash.

```ruby
game_score = Parse::Object.new "GameScore", {
  "score" => 1337, "playerName" => "Sean Plott", "cheatMode" => false
}
```

Or if you prefer, you can use symbols for the hash keys - they will be converted to strings
by ```Parse::Object.initialize()```.

```ruby
game_score = Parse::Object.new "GameScore", {
    :score => 1337, :playerName => "Sean Plott", :cheatMode => false
}
```

### ActiveRecord-style Models

I like ActiveRecord-style models, but I also want to avoid ActiveRecord-style model bloat. `Parse::Model` is just a subclass of `Parse::Object` that passes the class name into the `initialize` method.

```ruby
class Post < Parse::Model
end
```

The entire source for `Parse::Model` is just seven lines of simple Ruby:

```ruby
module Parse
  class Model < Parse::Object
    def initialize
      super(self.class.to_s)
    end
  end
end
```

## Retrieving Objects

Individual objects can be retrieved with a single call to ```Parse.get()``` supplying the class and object id.

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

### Relational Data

```ruby
post = Parse::Object.new "Post"
post.save

comment = Parse::Object.new "Comment"
comment.save

post.array_add_relation("comments", comment.pointer)
post.save

q = Parse::Query.new("Comment")
q.related_to("comments", post.pointer)
comments = q.get
assert_equal comments.first["objectId"], comment["objectId"]
```

## Push Notifications

```ruby
push = Parse::Push.new({"alert" => "I'm sending this push to all my app users!"})
push.save
```

## Batch Requests

Automagic:

```ruby
posts = Parse::Query.new("Post").get
update_batch = Parse::Batch.new
posts.each_slice(20) do |posts_slice|
  posts_slice.each do |post|
    post["title"] = "Updated title!"
    update_batch.update_object(post)
  end
end
update_batch.run!
```

`Parse::Batch` also has `#create_object` and `delete_object` methods. Both take instances of `Parse::Object` as the only argument.

Manual:

```ruby
batch = Parse::Batch.new
batch.add_request({
  "method" => "POST",
  "path" => "/1/classes/GameScore",
  "body" => {
    "score" => 1337,
    "playerName" => "Sean Plott"
  }
})
resp = batch.run!
```

## Cloud Code

```ruby
# assumes you have a function named "trivial"
function = Parse::Cloud::Function.new("trivial")
params = {"foo" => "bar"}
function.call(params)
```

# TODO

- Add some form of debug logging
- ~~Support for Date, Pointer, and Bytes API [data types](https://www.parse.com/docs/rest#objects-types)~~
- ACLs
- Login


# Resources

- parse.com [REST API documentation](https://parse.com/docs/rest)
- [parse_resource](https://github.com/adelevie/parse_resource) , an ActiveRecord-compatible wrapper
  for the API for seamless integration into Rails.

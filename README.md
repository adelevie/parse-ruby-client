# !! NOTE !!
The master branch has a lot of changes that the current release doesn't have.

The version on RubyGems (0.3.0) has its [corresponding tag](https://github.com/adelevie/parse-ruby-client/tree/v0.3.0), so use those docs instead.

Alternatively, you can set up your `Gemfile` as such:


```ruby
gem 'parse-ruby-client', git: 'https://github.com/adelevie/parse-ruby-client.git'
```

and it'll use the current master branch in your app.

## Summary

parse-ruby-client lets you interact with Parse using Ruby. There are many uses. For example:

- a web application can show data from Parse on a website.
- you can upload large amounts of data that will later be consumed in a mobile app.
- you can download recent data to run your own custom analytics.
- you can export all of your data if you no longer want to use Parse.

### Quick Reference

#### Installation

`gem install parse-ruby-client` or add `gem "parse-ruby-client"` to your `Gemfile.`

#### Client initialization

```ruby
require 'parse-ruby-client'

Parse.create :application_id => "<your_app_id>", # required
             :api_key        => "<your_api_key>", # required
             :quiet          => true | false  # optional, defaults to false
```
You can also specify your host if you are hosting your own parse-server:

```ruby
require 'parse-ruby-client'

Parse.create :application_id => "<your_app_id>", # required
             :api_key        => "<your_api_key>", # required
             :quiet          => true | false  # optional, defaults to false
             :host           => "http://custom-parse-server-without-backslash"

```
Please specify the url you mounted the api server without backslash as the ``host`` when
instantiating the ``client``

[![Gem Version](https://img.shields.io/gem/v/parse-ruby-client.svg)](http://badge.fury.io/rb/parse-ruby-client)

[![Travis](https://img.shields.io/travis/adelevie/parse-ruby-client.svg)](https://travis-ci.org/adelevie/parse-ruby-client)

[![Coverage Status](https://coveralls.io/repos/adelevie/parse-ruby-client/badge.svg?branch=master&service=github)](https://coveralls.io/github/adelevie/parse-ruby-client?branch=master)

[![Code Climate](https://img.shields.io/codeclimate/github/adelevie/parse-ruby-client.svg)](https://codeclimate.com/github/adelevie/parse-ruby-client)

**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [Summary](#summary)
  - [Quick Reference](#quick-reference)
    - [Installation](#installation)
    - [Configuration](#configuration)
- [Parse App Config Parameters](#parse-app-config-parameters)
- [Objects](#objects)
  - [Creating Objects](#creating-objects)
  - [Retrieving Objects](#retrieving-objects)
  - [Updating Objects](#updating-objects)
    - [Counters](#counters)
    - [Arrays](#arrays)
    - [Relations](#relations)
- [TODO: This method is not yet implemented.](#todo:-this-method-is-not-yet-implemented)
    - [Deleting Objects](#deleting-objects)
- [TODO: This method is not yet implemented.](#todo:-this-method-is-not-yet-implemented)
    - [Batch Operations](#batch-operations)
- [making a few GameScore objects](#making-a-few-gamescore-objects)
    - [Data Types](#data-types)
      - [Dates](#dates)
      - [Bytes](#bytes)
      - [Pointers](#pointers)
      - [Relation](#relation)
- [TODO: There is no Ruby object representation of this type, yet.](#todo:-there-is-no-ruby-object-representation-of-this-type-yet)
      - [Future data types and namespacing](#future-data-types-and-namespacing)
  - [Queries](#queries)
    - [Basic Queries](#basic-queries)
    - [Query Contraints](#query-contraints)
    - [Queries on Array Values](#queries-on-array-values)
    - [Relational Queries](#relational-queries)
    - [Counting Objects](#counting-objects)
    - [Compound Queries](#compound-queries)
  - [Users](#users)
    - [Signing Up](#signing-up)
    - [Logging In](#logging-in)
    - [Verifying Emails](#verifying-emails)
    - [Requesting A Password Reset](#requesting-a-password-reset)
    - [Retrieving Users](#retrieving-users)
    - [Updating Users](#updating-users)
    - [Querying](#querying)
    - [Deleting Users](#deleting-users)
    - [Linking Users](#linking-users)
      - [Signing Up and Logging In](#signing-up-and-logging-in)
- [should look something like this:](#should-look-something-like-this:)
      - [Linking](#linking)
- [should look something like this:](#should-look-something-like-this:)
- [or](#or)
      - [Unlinking](#unlinking)
- [should look something like this:](#should-look-something-like-this:)
    - [Security](#security)
  - [Roles](#roles)
  - [Files](#files)
    - [Uploading Files](#uploading-files)
    - [Associating with Objects](#associating-with-objects)
    - [Deleting Files](#deleting-files)
  - [Push Notifications](#push-notifications)
    - [Using Channels](#using-channels)
    - [Using Advanced Targeting](#using-advanced-targeting)
  - [Installations](#installations)
  - [GeoPoints](#geopoints)
    - [GeoPoint](#geopoint)
    - [GeoQueries](#geoqueries)
- [should look something like this:](#should-look-something-like-this:)
    - [Caveats](#caveats)

## Parse App Config Parameters

[Application config parameters](https://parse.com/docs/rest#config) are read-only and must be set via the Parse web application. However, you can access the values with:

```ruby
client.application_config # => {"welcomeMessage" => "Welcome to The Internet!", "winningNumber" => 42}
```

## Objects

The design philosophy behind parse-ruby-client is to stay out of the way as much as possible. Parse Objects, at the most basic level, act like Ruby `Hash` objects with Parse-specific methods tacked on.

### Creating Objects

```ruby
game_score = client.object("GameScore")
game_score["score"] = 1337
game_score["playerName"] = "Sean Plott"
game_score["cheatMode"] = false
result = game_score.save
puts result
```

This will return:

```ruby
{"score"=>1337,
 "playerName"=>"Sean Plott",
 "cheatMode"=>false,
 "createdAt"=>"2013-01-19T21:01:33.562Z",
 "objectId"=>"GeqPWJdNqp"}
```

### Retrieving Objects

The easiest way to retrieve Objects is with `client.query`:

```ruby
game_score_query = client.query("GameScore")
game_score_query.eq("objectId", "GeqPWJdNqp")
game_score = game_score_query.get
puts game_score
```

This will return:

```ruby
[{"score"=>1337,
  "playerName"=>"Sean Plott",
  "createdAt"=>"2013-01-19T21:01:33.562Z",
  "updatedAt"=>"2013-01-19T21:01:33.562Z",
  "objectId"=>"GeqPWJdNqp"}]
```

Notice that this is an `Array` of results. For more information on queries, see [Queries](#queries).

When retrieving objects that have pointers to children, you can fetch child objects by setting the `include` attribute. For instance, to fetch the object pointed to by the "game" key:

```ruby
game_score_query = client.query("GameScore")
game_score_query.eq("objectId", "GeqPWJdNqp")
game_score_query.include = "game"
game_score = game_score_query.get
```

You can include multiple children pointers by separating key names by commas:

```ruby
game_score_query.include = "game,genre"
```

### Updating Objects

To change the data on an object that already exists, just call `Parse::Object#save` on it. Any keys you don't specify will remain unchanged, so you can update just a subset of the object's data. For example, if we wanted to change the score field of our object:

```ruby
game_score = client.query("GameScore").eq("objectId", "GeqPWJdNqp").get.first
game_score["score"] = 73453
result = game_score.save
puts result
```

This will return:

```ruby
{"score"=>73453,
 "playerName"=>"Sean Plott",
 "createdAt"=>"2013-01-19T21:01:33.562Z",
 "updatedAt"=>"2013-01-19T21:16:34.395Z",
 "objectId"=>"GeqPWJdNqp"}
```

#### Counters

To help with storing counter-type data, Parse provides the ability to atomically increment (or decrement) any number field. So, we can increment the score field like so:

```ruby
game_score = client.query("GameScore").eq("objectId", "GeqPWJdNqp").get.first
game_score["score"] = Parse::Increment.new(1)
game_score.save
```

You can also use a negative amount to decrement.

#### Arrays

To help with storing array data, there are three operations that can be used to atomically change an array field:

1. `Parse::Object#array_add(field, value)` appends the given array of objects to the end of an array field.
2. `Parse::Object#array_add_unique(field, value)` adds only the given objects which aren't already contained in an array field to that field. The position of the insert is not guaranteed.
3. `Parse::Object#array_remove(field, value)` removes all instances of each given object from an array field.

Each method takes an array of objects to add or remove in the "objects" key. For example, we can add items to the set-like "skills" field like so:

```ruby
game_score = client.query("GameScore").eq("objectId", "5iEEIxM4MW").get.first
game_score.array_add_unique("skills", ["flying", "kungfu"])
game_score.save
puts game_score["skills"]
```

This will return:

```ruby
[["flying", "kungfu"]]
```

#### Relations

In order to update Relation types, Parse provides special operators to atomically add and remove objects to a relation. So, we can add an object to a relation like so:

```ruby
game_score = client.query("GameScore").eq("objectId", "5iEEIxM4MW").get.first
player = client.query("Player").eq("objectId", "GLtvtEaGKa").get.first
game_score.array_add_relation("opponents", player.pointer)
game_score.save
game_score["opponents"] #=> #<Parse::ArrayOp:0x007fbe98931508 @operation="AddRelation", @objects=[Player:GLtvtEaGKa]>
game_score["opponents"].objects.first #=> Player:GLtvtEaGKa
```

To remove an object from a relation, you can do:

```ruby
game_score.array_remove_relation("opponents", player.pointer)
```

### Deleting Objects

To delete an object from the Parse Cloud, call `Parse::Object#parse_delete`. For example:

```ruby
game_score = client.query("GameScore").eq("objectId", "5iEEIxM4MW").get.first
game_score.parse_delete
client.query("GameScore").eq("objectId", "5iEEIxM4MW").get.length #=> 0
```

You can delete a single field from an object by using the `Parse::Object#delete_field` operation:

```ruby
# TODO: This method is not yet implemented.
```

### Batch Operations

To reduce the amount of time spent on network round trips, you can create, update, or delete several objects in one call, using the batch endpoint.

parse-ruby-client provides a "manual" way to construct Batch Operations, as well as some convenience methods. The commands are run in the order they are given. For example, to create a couple of GameScore objects using the "manual" style, use `Parse::Batch#add_request`. `#add_request` takes a `Hash` with `"method"`, `"path"`, and `"body"` keys that specify the HTTP command that would normally be used for that command.

```ruby
batch = client.batch
batch.add_request({
  "method" => "POST",
  "path"   => "/1/classes/GameScore"
  "body"   => {
    "score"      => 1337,
    "playerName" => "Sean Plott"
  }
})
batch.add_request({
  "method" => "POST",
  "path"   => "/1/classes/GameScore"
  "body"   => {
    "score"      => 1338,
    "playerName" => "ZeroCool"
  }
})
batch.run!
```

Because manually constructing `"path"` values is repetitive, you can use `Parse::Batch#create_object`, `Parse::Batch#update_object`, and `Parse::Batch#delete_object`. Each of these methods takes an instance of `Parse::Object` as the only argument. Then you just call `Parse::Batch#run!`. For example:

```ruby
batch = client.batch
# making a few GameScore objects and adding them to the batch operation.
[1, 2, 3, 4, 5].each do |i|
  gs = Parse::Object.new("GameScore")
  gs["score"] = "#{i}"
  batch.create_object(gs)
end
batch.run!
```

The response from batch will be an `Array` with the same number of elements as the input list. Each item in the `Array` will be a `Hash` with either the `"success"` or `"error"` field set. The value of success will be the normal response to the equivalent REST command:

```ruby
{
  "success" => {
    "createdAt" => "2012-06-15T16:59:11.276Z",
    "objectId"  => "YAfSAWwXbL"
  }
}
```

The value of `"error"` will be a `Hash` with a numeric code and error string:

```ruby
{
  "error" => {
    "code"  => 101,
    "error" => "object not found for delete"
  }
}
```

### Data Types

So far we have only used values that can be encoded with standard JSON. The Parse mobile client libraries also support dates, binary data, and relational data. In parse-ruby-client, these values are encoded as JSON hashes with the __type field set to indicate their type, so you can read or write these fields if you use the correct encoding. See https://github.com/adelevie/parse-ruby-client/blob/master/lib/parse/datatypes.rb for implementation details of several common data types.

#### Dates

Use `Parse::Date::new` to create a date object:

```ruby
date_time = DateTime.now
parse_date = Parse::Date.new(date_time)
```

Dates are useful in combination with the built-in createdAt and updatedAt fields. For example, to retrieve objects created since a particular time, just encode a Date in a comparison query:

```ruby
game_score = client.query("GameScore").tap do |q|
  q.greater_than("createdAt", Parse::Date.new(DateTime.now)) # query options explained in more detail later in this document
end.get.first
```

`Parse::Date::new` can take a `DateTime`, iso `Hash`, or a `String` that can be parsed by `DateTime#parse` as the sole argument.

The `Parse::Date` API is not set in stone and will likely change following the suggestions discussed here: https://github.com/adelevie/parse-ruby-client/issues/35. The current methods probably will not go away, but some newer, easier methods will be added.

#### Bytes

`Parse::Bytes` contains an attribute, `base64`, which contains a base64 encoding of binary data. The specific base64 encoding is the one used by MIME, and does not contain whitespace.

```ruby
data = "TG9va3MgbGlrZSB5b3UgZm91bmQgYW4gZWFzdGVyIEVnZy4gTWF5YmUgaXQn\ncyB0aW1lIHlvdSB0b29rIGEgTWluZWNyYWZ0IGJyZWFrPw==\n" # base64 encoded data
bytes = Parse::Bytes.new(data)
```

#### Pointers

The `Pointer` type is used when mobile code sets a `PFObject` (iOS SDK) or `ParseObject` (Android SDK) as the value of another object. It contains the `className` and `objectId` of the referred-to value.

```ruby
pointer = Parse::Pointer.new({"className" => "gameScore", "objectId" => "GeqPWJdNqp"})
```

Pointers to `user` objects have a `className` of `_User`. Prefixing with an underscore is forbidden for developer-defined classes and signifies the class is a special built-in.

If you already have a `Parse::Object`, you can get its `Pointer` very easily:

```ruby
game_score.pointer
```

#### Relation

The `Relation` type is used for many-to-many relations when the mobile uses `PFRelation` (iOS SDK) or `ParseRelation` (Android SDK) as a value. It has a `className` that is the class name of the target objects.

*Note:* The REST API embeds the configuration parameters in a key called 'params' which is omitted for you by the client.

```ruby
# TODO: There is no Ruby object representation of this type, yet.
```

#### Future data types and namespacing

Though this is something parse-ruby-client will take care for you, it's worth noting:

When more data types are added, they will also be represented as hashes with a `__type` field set, so you may not use this field yourself on JSON objects.


## Queries

Queries are created like so:

```ruby
query = client.query("GameScore")
```



### Basic Queries

You can retrieve multiple objects at once by calling `#get`:

```ruby
query.get
```

The return value is an `Array` of `Parse::Object` instances:

```ruby
[{"score"=>100,
  "player"=>player:qPHDUbBbjj,
  "createdAt"=>"2012-10-10T00:16:10.846Z",
  "updatedAt"=>"2012-10-10T00:16:10.846Z",
  "objectId"=>"6ff54A5OCY"},
 {"score"=>1337,
  "playerName"=>"Sean Plott",
  "createdAt"=>"2013-01-05T22:51:56.033Z",
  "updatedAt"=>"2013-01-05T22:51:56.033Z",
  "objectId"=>"MpPBAHsqNg"},
 {"score"=>1337,
  "playerName"=>"Sean Plott",
  "createdAt"=>"2013-01-05T22:53:22.609Z",
  "updatedAt"=>"2013-01-05T22:53:22.609Z",
  "objectId"=>"T1dj8cWwYJ"}]]
```

### Query Contraints

There are several ways to put constraints on the objects found, using various methods of `Parse::Query`. The most basic is `Parse::Query#eq`:

```ruby
query = client.query("GameScore").eq("playerName", "Sean Plott")
```

Other constraint methods include:

<table>
  <tr>
    <td>`#less_than(field, value)`</td>
    <td>Less Than</td>
  </tr>
  <tr>
    <td>`#less_eq(field, value)`</td>
    <td>Less Than or Equal To</td>
  </tr>
  <tr>
    <td>`#greater_than(field, value)`</td>
    <td>Greater Than</td>
  </tr>
  <tr>
    <td>`#greater_eq(field, value)`</td>
    <td>Greater Than Or Equal To</td>
  </tr>
  <tr>
    <td>`#not_eq(field, value)`</td>
    <td>Not Equal To</td>
  </tr>
  <tr>
    <td>`#value_in(field, values)`</td>
    <td>Contained In</td>
  </tr>
  <tr>
    <td>`#value_not_in(field, values)`</td>
    <td>Not Contained in</td>
  </tr>
  <tr>
    <td>`#exists(field, value=true)`</td>
    <td>A value is set for the key</td>
  </tr>
  <tr>
    <td>`#contains_all(field, values)`</td>
    <td>Contains all values in the array</td>
  </tr>
  <tr>
    <td>`Parse::Query#select`</td>
    <td>TODO: `$select` not yet implemented. This matches a value for a key in the result of a different query</td>
  </tr>
</table>

For example, to retrieve scores between 1000 and 3000, including the endpoints, we could issue:

```ruby
scores = client.query("GameScore").tap do |q|
  q.greater_eq("score", 1000)
  q.less_eq("score", 3000)
end.get
```

To retrieve scores equal to an odd number below 10, we could issue:

```ruby
scores = client.query("GameScore").tap do |q|
  q.value_in("score", [1,3,5,7,9])
end.get
```

To retrieve scores not by a given list of players we could issue:

```ruby
scores = client.query("GameScore").tap do |q|
  q.value_not_in("playerName", ["Jonathan Walsh","Dario Wunsch","Shawn Simon"])
end.get
```

To retrieve documents with the score set, we could issue:

```ruby
scores = client.query("GameScore").tap do |q|
  q.exists("score") # defaults to `true`
end.get
```

To retrieve documents without the score set, we could issue:

```ruby
scores = client.query("GameScore").tap do |q|
  q.exists("score", false)
end.get
```

If you have a class containing sports teams and you store a user's hometown in the user class, you can issue one query to find the list of users whose hometown teams have winning records. The query would look like:

```ruby
users = client.query("_User").tap do |users_query|
  users_query.eq("hometown", {
    "$select" => {
      "query" => {
        "className" => "Team",
        "where" => {
          "winPct" => {"$gt" => 0.5}
        }
      },
    "key" => "city"
    }
  })
end.get
```

Currently, there is no convenience method provided for `$select` queries. However, they are still possible. This is a good example of the flexibility of parse-ruby-client. You usually do not need to wait for a feature to be added in order to user it. If you have a good idea on what a convencience method for this should look like, please file an issue, or even better, submit a pull request.

You can use the `Parse::Query#order_by` method to specify a field to sort by. By default, everything is ordered ascending. Thus, to retrieve scores in ascending order:

```ruby
scores = client.query("GameScore").tap do |q|
  q.order_by = "score"
end.get
```

And to retrieve scores in descending order:

```ruby
scores = client.query("GameScore").tap do |q|
  q.order_by = "score"
  q.order = :descending
end.get
```

You can sort by multiple fields by passing order a comma-separated list. Currently, there is no convenience method to accomplish this. However, you can still manually construct an `order` string. To retrieve documents that are ordered by scores in ascending order and the names in descending order:

```ruby
scores = client.query("GameScore").tap do |q|
  q.order_by = "score,-name"
end.get
```

You can use the `limit` and `skip` parameters for pagination. `limit` defaults to 100, but anything from 1 to 1000 is a valid limit. Thus, to retrieve 200 objects after skipping the first 400:

```ruby
scores = client.query("GameScore").tap do |q|
  q.limit = 200
  q.skip = 400
end.get
```

You can use `keys` to only get specified fields back. `objectId`, `createdAt`, and `updatedAt` are always returned, and other fields are supplied as a comma separated string.

```ruby
scores = Parse::Query.new("GameScore").tap do |q|
  q.keys = "score,name"
end.get
```


All of these parameters can be used in combination with each other.

### Queries on Array Values

For keys with an array type, you can find objects where the key's array value contains 2 by:

```ruby
randos = client.query("RandomObject").eq("arrayKey", 2).get
```

You can also query that the array contains multiple objects by using contains all, for example you can return objects that have the array values 2 AND 3 by:

```ruby
randos = client.query("RandomObject").eq("arrayKey", [2, 3]).get
```

### Relational Queries

There are several ways to issue queries for relational data. For example, if each `Comment` has a `Post` object in its `post` field, you can fetch comments for a particular `Post`:

```ruby
comments = client.query("Comment").tap do |q|
  q.eq("post", Parse::Pointer.new({
    "className" => "Post",
    "objectId"  => "8TOXdXf3tz"
  }))
end.get
```

If you want to retrieve objects where a field contains an object that matches another query, you can use the `Parse::Query#in_query(field, query=nil)` method. Note that the default limit of 100 and maximum limit of 1000 apply to the inner query as well, so with large data sets you may need to construct queries carefully to get the desired behavior. For example, imagine you have `Post` class and a `Comment` class, where each `Comment` has a relation to its parent `Post`. You can find comments on posts with images by doing:

```ruby
comments = client.query("Comment").tap do |comments_query|
  comments_query.in_query("post", client.query("Post").tap do |posts_query|
    posts_query.exists("image")
  end)
end.get
```

Note: You must pass an instance of `Parse::Query` as the second argument for `Parse::Query#query_in`. You cannot manually construct queries for this.

TODO: Implement this:
```
If you want to retrieve objects where a field contains an object that does not match another query, you can use the $notInQuery operator. Imagine you have Post class and a Comment class, where each Comment has a relation to its parent Post. You can find comments on posts without images by doing:
```

If you want to retrieve objects that are members of `Relation` field of a parent object, you can use the `Parse::Query#related_to(field, value)` method. Imagine you have a `Post `class and `User` class, where each `Post` can be liked by many users. If the `Users` that liked a Post was stored in a `Relation` on the post under the key likes, you, can the find the users that liked a particular post by:

```ruby
users = client.query("_User").tap do |q|
  q.related_to("likes", Parse::Pointer.new({
    "className" => "Post",
    "objectId" => "8TOXdXf3tz"
  }))
end.get
```

In some situations, you want to return multiple types of related objects in one query. You can do this by passing the field to include in the `include` parameter. For example, let's say you are retrieving the last ten comments, and you want to retrieve their related posts at the same time:

```ruby
comments = client.query("Comment").tap do |q|
  q.order_by = "createdAt"
  q.order    = :descending
  q.limit    = 10
  q.include  = "post"
end.get
```

Instead of being represented as a `Pointer`, the `post` field is now expanded into the whole object. `__type` is set to `Object` and `className` is provided as well. For example, a `Pointer` to a `Post` could be represented as:

```ruby
{
  "__type" => "Pointer",
  "className" => "Post",
  "objectId" => "8TOXdXf3tz"
}
```

When the query is issued with an `include` parameter for the key holding this pointer, the pointer will be expanded to:

```ruby
{
  "__type" => "Object",
  "className" => "Post",
  "objectId" => "8TOXdXf3tz",
  "createdAt" => "2011-12-06T20:59:34.428Z",
  "updatedAt" => "2011-12-06T20:59:34.428Z",
  "otherFields" => "willAlsoBeIncluded"
}
```

You can also do multi level includes using dot notation. If you wanted to include the post for a comment and the post's author as well you can do:

```ruby
comments = client.query("Comment").tap do |q|
  q.order_by = "createdAt"
  q.order    = :descending
  q.limit    = 10
  q.include  = "post.author"
end.get
```

You can issue a query with multiple fields included by passing a comma-separated list of keys as the include parameter:

```ruby
comments = client.query("Comment").tap do |q|
  q.include("post,author")
comments = Parse::Query.new("Comment").tap do |q|
  q.include = "post,author"
end.get
```

### Counting Objects

If you are limiting your query, or if there are a very large number of results, and you want to know how many total results there are without returning them all, you can use the `count` parameter. For example, if you only care about the number of games played by a particular player:

```ruby
count = client.query("GameScore").tap do |q|
  q.eq("playerName", "Jonathan Walsh")
  q.limit = 0
  q.count
end.get
```

With a nonzero limit, that request would return results as well as the count.

### Compound Queries

If you want to find objects that match one of several queries, you can use `Parse::Query#or` method, with an `Array` as its value. For instance, if you want to find players with either have a lot of wins or a few wins, you can do:

```ruby

players = client.query("Player").tap do |q|
  q.greater_than("wins", 150)
  q.or(client.query("Player").tap do |or_query|
    or_query.less_than("wins, 5")
  end)
end.get
```

## Users

Many apps have a unified login that works across the mobile app and other systems. Accessing user accounts through parse-ruby-client lets you build this functionality on top of Parse.

In general, users have the same features as other objects, such as the flexible schema. The differences are that user objects must have a username and password, the password is automatically encrypted and stored securely, and Parse enforces the uniqueness of the `username` and `email` fields.

### Signing Up

Signing up a new user differs from creating a generic object in that the `username` and `password` fields are required. The password field is handled differently than the others; it is encrypted when stored in the Parse Cloud and never returned to any client request.

You can ask Parse to verify user email addresses in your application settings page. With this setting enabled, all new user registrations with an `email` field will generate an email confirmation at that address. You can check whether the user has verified their `email` with the `emailVerified` field.

To sign up a new user, create a new `Parse::User` object and then call `#save` on it:

```ruby
user = client.user({
  :username => "cooldude6",
  :password => "p_n7!-e8",
  :phone => "415-392-0202"
})
user.save
```

The response body is a `Parse::User` object containing the `objectId`, the `createdAt` timestamp of the newly-created object, and the `sessionToken` which can be used to authenticate subsequent requests as this user:

```ruby
{"username"=>"cooldude6",
 "phone"=>"415-392-0202",
 "createdAt"=>"2013-01-31T15:22:40.339Z",
 "objectId"=>"2bMfWZQ9Ob",
 "sessionToken"=>"zrGuvs3psdndaqswhf0smupsodflkqbFdwRs"}
```

### Logging In

After you allow users to sign up, you need to let them log in to their account with a username and password in the future. To do this, call `Parse::User#authenticate(username, password)`:

```ruby
user = Parse::User.authenticate("cooldude6", "p_n7!-e8", client)
```

The response body is a `Parse::User` object containing all the user-provided fields except `password`. It also contains the `createdAt`, `updatedAt`, `objectId`, and `sessionToken` fields:

```ruby
{"username"=>"cooldude6",
 "phone"=>"415-392-0202",
 "createdAt"=>"2013-01-31T15:22:40.339Z",
 "updatedAt"=>"2013-01-31T15:22:40.339Z",
 "objectId"=>"2bMfWZQ9Ob",
 "sessionToken"=>"uvs3aspasdnlksdasqu178qaq0smupso"}
```

### Verifying Emails

Enabling email verification in an application's settings allows the application to reserve part of its experience for users with confirmed email addresses. Email verification adds the `emailVerified` field to the `User` object. When a `User`'s `email` is set or modified, `emailVerified` is set to false. Parse then emails the user a link which will set `emailVerified` to `true`.

There are three `emailVerified` states to consider:

1. `true` - the user confirmed his or her email address by clicking on the link Parse emailed them. `Users` can never have a `true` value when the user account is first created.

2. `false` - at the time the `User` object was last refreshed, the user had not confirmed his or her email address. If `emailVerified` is `false`, consider refreshing the `User` object.

3. *missing* - the `User` was created when email verification was off or the `User` does not have an `email`.

### Requesting A Password Reset

You can initiate password resets for users who have emails associated with their account. To do this, use `Parse::User::reset_password`:

```ruby
resp = Parse::User.reset_password("coolguy@iloveapps.com", client)
puts resp #=> {}
```

If successful, the response body is an empty `Hash` object.

### Retrieving Users

You can also retrieve the contents of a user object by using `Parse::Query`. For example, to retrieve the user created above:

```ruby
user = client.query("_User").eq("objectId", "2bMfWZQ9Ob").get.first
```

The response body is a `Parse::User` object containing all the user-provided fields except `password`. It also contains the `createdAt`, `updatedAt`, and `objectId` fields:

```ruby
{"username"=>"cooldude6",
 "phone"=>"415-392-0202",
 "createdAt"=>"2013-01-31T15:22:40.339Z",
 "updatedAt"=>"2013-01-31T15:22:40.339Z",
 "objectId"=>"2bMfWZQ9Ob"}
```

### Updating Users

TODO: Implement this!

In normal usage, nobody except the user is allowed to modify their own data. To authenticate themselves, the user must add a `X-Parse-Session-Token` header to the request with the session token provided by the signup or login method.

To change the data on a user that already exists, send a PUT request to the user URL. Any keys you don't specify will remain unchanged, so you can update just a subset of the user's data. `username` and `password` may be changed, but the new username must not already be in use.

For example, if we wanted to change the phone number for cooldude6:

```ruby
user = client.query("_User").eq("objectId", "2bMfWZQ9Ob").get.first
user["phone"] = "415-369-6201"
user.save
```

Currently returns the following error:

```
Parse::ParseProtocolError: 206: Parse::UserCannotBeAlteredWithoutSessionError
```

### Querying

You can retrieve multiple users at once by using `Parse::Query`:

```ruby
users = client.query("_User").get
```

The return value is an `Array` of `Parse::User` objects:

```ruby
[{"username"=>"fake_person",
  "createdAt"=>"2012-04-20T20:07:32.295Z",
  "updatedAt"=>"2012-04-20T20:07:32.295Z",
  "objectId"=>"AAVwfClOx9"},
 {"username"=>"fake_person222",
  "createdAt"=>"2012-04-20T20:07:32.946Z",
  "updatedAt"=>"2012-04-20T20:07:32.946Z",
  "objectId"=>"0W1Gj1CXqU"}]
```

All of the options for queries that work for regular objects also work for user objects, so check the section on Querying Objects for more details.

### Deleting Users

TODO: Implement this!

Proposed api:

To delete a user from the Parse Cloud, call `#parse_delete` on it:

```ruby
user.parse_delete
```

### Linking Users

TODO: Implement this! See https://parse.com/docs/rest#users-linking

Parse allows you to link your users with services like Twitter and Facebook, enabling your users to sign up or log into your application using their existing identities. This is accomplished through the sign-up and update REST endpoints by providing authentication data for the service you wish to link to a user in the authData field. Once your user is associated with a service, the authData for the service will be stored with the user and is retrievable by logging in.

authData is a JSON object with keys for each linked service containing the data below. In each case, you are responsible for completing the authentication flow (e.g. OAuth 1.0a) to obtain the information the the service requires for linking.

Facebook authData contents:

```ruby
{
  "facebook" => {
    "id" => "user's Facebook id number as a string",
    "access_token" => "an authorized Facebook access token for the user",
    "expiration_date" => "token expiration date of the format: yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
  }
}
```

Twitter authData contents:

```ruby
{
  "twitter" => {
    "id" => "user's Twitter id number as a string",
    "screen_name" => "user's Twitter screen name",
    "consumer_key" => "your application's consumer key",
    "consumer_secret" => "your application's consumer secret",
    "auth_token" => "an authorized Twitter token for the user with your application",
    "auth_token_secret" => "the secret associated with the auth_token"
  }
}
```

Anonymous user authData contents:

```ruby
{
  "anonymous" => {
    "id" => "random UUID with lowercase hexadecimal digits"
  }
}
```

#### Signing Up and Logging In

Todo: Implement this!

Signing a user up with a linked service and logging them in with that service uses the same POST request, in which the authData for the user is specified. For example, to sign up or log in with a user's Twitter account:

```ruby
# should look something like this:
twitter_user = Parse::User::Twitter.new({
  "id" => "12345678",
  "screen_name" => "ParseIt",
  "consumer_key" => "SaMpLeId3X7eLjjLgWEw",
  "consumer_secret" => "SaMpLew55QbMR0vTdtOACfPXa5UdO2THX1JrxZ9s3c",
  "auth_token" => "12345678-SaMpLeTuo3m2avZxh5cjJmIrAfx4ZYyamdofM7IjU",
  "auth_token_secret" => "SaMpLeEb13SpRzQ4DAIzutEkCE2LBIm2ZQDsP3WUU"
})
twitter_user.save
```

Parse then verifies that the provided authData is valid and checks to see if a user is already associated with this data. If so, it returns a status code of 200 OK and the details (including a sessionToken for the user).

With a response body like:

```ruby
{
  "username" => "Parse",
  "createdAt" => "2012-02-28T23:49:36.353Z",
  "updatedAt" => "2012-02-28T23:49:36.353Z",
  "objectId" => "uMz0YZeAqc",
  "sessionToken" => "samplei3l83eerhnln0ecxgy5",
  "authData" => {
    "twitter" => {
      "id" => "12345678",
      "screen_name" => "ParseIt",
      "consumer_key" => "SaMpLeId3X7eLjjLgWEw",
      "consumer_secret" => "SaMpLew55QbMR0vTdtOACfPXa5UdO2THX1JrxZ9s3c",
      "auth_token" => "12345678-SaMpLeTuo3m2avZxh5cjJmIrAfx4ZYyamdofM7IjU",
      "auth_token_secret" => "SaMpLeEb13SpRzQ4DAIzutEkCE2LBIm2ZQDsP3WUU"
    }
  }
}
```

If the user has never been linked with this account, you will instead receive a status code of 201 Created, indicating that a new user was created.

The body of the response will contain the objectId, createdAt, sessionToken, and an automatically-generated unique username. For example:

```ruby
{
  "username" => "iwz8sna7sug28v4eyu7t89fij",
  "createdAt" => "2012-02-28T23:49:36.353Z",
  "objectId" => "uMz0YZeAqc",
  "sessionToken" => "samplei3l83eerhnln0ecxgy5"
}
```

#### Linking

TODO: Implement this!

Linking an existing user with a service like Facebook or Twitter uses a PUT request to associate authData with the user. For example, linking a user with a Facebook account would use a request like this:

```ruby
# should look something like this:

user = client.query("_User").eq("objectId", "2bMfWZQ9Ob").get.first
user.link_to_facebook!({
  "id" => "123456789",
  "access_token" => "SaMpLeAAibS7Q55FSzcERWIEmzn6rosftAr7pmDME10008bWgyZAmv7mziwfacNOhWkgxDaBf8a2a2FCc9Hbk9wAsqLYZBLR995wxBvSGNoTrEaL",
  "expiration_date" => "2012-02-28T23:49:36.353Z"
})

# or

user.link_to_twitter!({...})
```

After linking your user to a service, you can authenticate them using matching authData.


#### Unlinking

TODO: Implement this!

Unlinking an existing user with a service also uses a PUT request to clear authData from the user by setting the authData for the service to null. For example, unlinking a user with a Facebook account would use a request like this:

```ruby
# should look something like this:

user = client.query("_User").eq("objectId", "2bMfWZQ9Ob").get.first
user.unlink_from_facebook!
```

### Security

TODO: Implement this!

When you access Parse via the REST API key, access can be restricted by ACL just like in the iOS and Android SDKs. You can still read and modify acls via the REST API, just by accessing the "ACL" key of an object.

The ACL is formatted as a JSON object where the keys are either object ids or the special key "*" to indicate public access permissions. The values of the ACL are "permission objects", JSON objects whose keys are the permission name and the value is always true.

For example, if you want the user with id "3KmCvT7Zsb" to have read and write access to an object, plus the object should be publicly readable, that corresponds to an ACL of:

```json
{
  "3KmCvT7Zsb": {
    "read": true,
    "write": true
  },
  "*": {
    "read": true
  }
}
```

If you want to access your data ignoring all ACLs, you can use the master key provided on the Dashboard. Instead of the X-Parse-REST-API-Key header, set the X-Parse-Master-Key header. For backward compatibility, you can also do master-level authentication using HTTP Basic Auth, passing the application id as the username and the master key as the password. For security, the master key should not be distributed to end users, but if you are running code in a trusted environment, feel free to use the master key for authentication.

## Roles

TODO: Implement this!

See https://parse.com/docs/rest#roles

## Files

### Uploading Files

To upload a file to Parse, use `Parse::File`. You must include the `"Content-Type"` parameter when instantiating. Keep in mind that files are limited to 10 megabytes. Here's a simple example that'll create a file named `hello.txt` containing a string:

```ruby
file = client.file({
  :body => "Hello World!",
  :local_filename => "hello.txt",
  :content_type => "text/plain"
})
file.save
```

The response body is a `Hash` object containing the name of the file, which is the original file name prefixed with a unique identifier in order to prevent name collisions. This means, you can save files by the same name, and the files will not overwrite one another.

```ruby
{"url"=>
  "http://files.parse.com/372fcbb9-7eae-4b9a-abc8-6da97fcac50d/98f06e15-d6e6-42a9-a9cd-7d28ec98052c-hello.txt",
 "name"=>"98f06e15-d6e6-42a9-a9cd-7d28ec98052c-hello.txt"}
```

To upload an image, the syntax is a little bit different. Here's an example that will upload the image parsers.jpg from the current directory:

```ruby
photo = client.file({
  :body => IO.read("test/parsers.jpg"),
  :local_filename => "parsers.jpg",
  :content_type => "image/jpeg"
})
photo.save
```

### Associating with Objects

After files are uploaded, you can associate them with Parse objects:

```ruby
photo = client.file({
  :body => IO.read("test/parsers.jpg"),
  :local_filename => "parsers.jpg",
  :content_type => "image/jpeg"
})
photo.save
player_profile = client.object("PlayerProfile").tap do |p|
  p["name"] = "All the Parsers"
  p["picture"] = photo
end.save
```

### Deleting Files

TODO: Implement this!

## Push Notifications

Parse allows you to send push notifications to iOS and Android devices.

Notifications by default are set for iOS and Android. You can set certain notifications to only be sent to iOS or Android by setting the `type` to `ios` or `android`.

For config/installation: https://parse.com/docs/rest#push and https://parse.com/docs/push_guide#top/REST

### Using Channels

To send a notification to the "Giants" channel, as given at: https://parse.com/docs/push_guide#sending-channels/REST.

```ruby
data = { :alert => "This is a notification from Parse" }
push = client.push(data, "Giants")
push.type = "ios"
push.save
```

Without a specific channel, by default it sends to all installations.

### Using Advanced Targeting

To send a notification to installations where `injuryReports` is `true`, as given at: https://parse.com/docs/push_guide#sending-queries/REST


```ruby
data = { :alert => "This is a notification from Parse" }
push = client.push(data)
push.type = "ios"
query = client.query(Parse::Protocol::CLASS_INSTALLATION).eq('injuryReports', true)
push.where = query.where
push.save
```

## Installations

#### Creating Installations

```ruby
installation = client.installation.tap do |i|
  i.device_token = 'mobile_app_device_token'
  i.device_type = 'ios'
  i.channels = ['my-channel-name']
end
installation.save
```

#### Retrieving Installations

```ruby
installation = client.installation('objectId').get
# Same as
installation = Parse::Installation.new('objectId', client)
installation.get
```

#### Updating installations

```ruby
installation = client.installation('objectId')
installation.channels = ['', 'my-channel-name']
installation.badge = 5
installation.save
```

## GeoPoints

Parse allows you to associate real-world latitude and longitude coordinates with an object. Adding a GeoPoint data type to a class allows queries to take into account the proximity of an object to a reference point. This allows you to easily do things like find out which user is closest to another user or which places are closest to a user.

### GeoPoint

To associate a point with an object you will need to embed a GeoPoint data type into your object. This is done by using a JSON object with __type set to the string GeoPoint and numeric values being set for the latitude and longitude keys. For example, to create an object containing a point under the "location" key with a latitude of 40.0 degrees and -30.0 degrees longitude:

```ruby
place = client.object("PlaceObject").tap do |p|
  p["location"] = Parse::GeoPoint.new({
    "latitude" => 40.0,
    "longitude" => -30.0
  })
end.save
```

### GeoQueries

TODO: Implement this!

Now that you have a bunch of objects with spatial coordinates, it would be nice to find out which objects are closest to a point. This can be done by using a GeoPoint data type with query on the field using $nearSphere. Getting a list of ten places that are closest to a user may look something like:

```ruby
# should look something like this:
places = client.query("PlaceObject").tap do |q|
  q.near("location", {
    "latitude" => 30.0,
    "longitude" => -20.0
  })
end.get
```

See https://parse.com/docs/rest#geo-query for the rest of the geo query types to be implemented.

### Caveats

At the moment there are a couple of things to watch out for:

1. Each PFObject class may only have one key with a PFGeoPoint object.

2. Points should not equal or exceed the extreme ends of the ranges. Latitude should not be -90.0 or 90.0. Longitude should not be -180.0 or 180.0. Attempting to use GeoPoint's with latitude and/or longitude outside these ranges will cause an error.

# Contributors

This project would not be where it is today without the generous help provided by its many contributors:

1. Adam Alpern (created this project) (https://github.com/aalpern) (https://www.gittip.com/on/github/aalpern/)
2. Eric Jensen (https://github.com/ericcj) (https://www.gittip.com/on/github/ericcj/)
3. Ben Cherry (https://github.com/bcherry) (https://www.gittip.com/bcherry/)
4. Tikhon Bernstam (https://github.com/tikhon) (https://www.gittip.com/on/github/tikhon/)
5. Tony Amoyal (https://github.com/tamoyal) (https://www.gittip.com/on/github/tamoyal/)
6. Glenn Goodrich (https://github.com/ruprict) (https://www.gittip.com/on/github/ruprict/)
7. Jeremy Schoenherr (https://github.com/jeremyschoenherr) (https://www.gittip.com/on/github/jeremyschoenherr/)
8. Dean Perry (https://github.com/deanperry) (https://www.gittip.com/deanperry/)
9. [vircheck](https://github.com/vircheck) (https://www.gittip.com/on/github/vircheck/)
10. Jacob Eiting (https://github.com/jeiting) (https://www.gittip.com/on/github/jeiting/)
11. Guy Maliar (https://github.com/gmaliar) (https://www.gittip.com/on/github/gmaliar/)
12. Ivan Fuller (https://github.com/ifuller) (https://www.gittip.com/on/github/ifuller/)
13. Leandro S. (https://github.com/lsiqueira) (https://www.gittip.com/on/github/lsiqueira/)
14. Brian Hammond (https://github.com/fictorial) (https://www.gittip.com/on/github/fictorial/)

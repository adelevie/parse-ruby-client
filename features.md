## Summary

parse-ruby-client lets you interact with Parse using Ruby. There are many uses. For example:

- A webserver can show data from Parse on a website.
- You can upload large amounts of data that will later be consumed in a mobile app.
- You can download recent data to run your own custom analytics.
- You can export all of your data if you no longer want to use Parse.

### Quick Reference

#### Installation

`gem install parse-ruby-client` or add `gem "parse-ruby-client"` to your `Gemfile.`

#### Configuration

```ruby
require 'parse-ruby-client'

Parse.init :application_id => "<your_app_id>",
           :api_key        => "<your_api_key>"
```

## Objects

The design philosophy behind parse-ruby-client is to stay out of the way as much as possible. Parse Objects, at the most basic level, act like Ruby `Hash` objects with Parse-specific methods tacked on.

### Creating Objects

```ruby
game_score = Parse::Object.new("GameScore")
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

The easiest way to retrieve Objects is with `Parse::Query`:

```ruby
game_score_query = Parse::Query.new("GameScore")
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

Notice that this is an `Array` of results. For more information on queries, see TODO.

When retrieving objects that have pointers to children, you can fetch child objects by setting the `include` attribute. For instance, to fetch the object pointed to by the "game" key:

```ruby
game_score_query = Parse::Query.new("GameScore")
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
game_score = Parse::Query.new("GameScore").eq("objectId", "GeqPWJdNqp").get.first
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
game_score = Parse::Query.new("GameScore").eq("objectId", "GeqPWJdNqp").get.first
game_score["score"] = Parse::Increment.new(1)
game_score.save
```

You can also use `Parse::Decrement.new(amount)`.

#### Arrays

To help with storing array data, there are three operations that can be used to atomically change an array field:

1. `Parse::Object#array_add(field, value)` appends the given array of objects to the end of an array field.
2. `Parse::Object#array_add_unique(field, value)` adds only the given objects which aren't already contained in an array field to that field. The position of the insert is not guaranteed.
3. `Parse::Object#array_remove(field, value)` removes all instances of each given object from an array field.

Each method takes an array of objects to add or remove in the "objects" key. For example, we can add items to the set-like "skills" field like so:

```ruby
game_score = Parse::Query.new("GameScore").eq("objectId", "5iEEIxM4MW").get.first
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
game_score = Parse::Query.new("GameScore").eq("objectId", "5iEEIxM4MW").get.first
player = Parse::Query.new("Player").eq("objectId", "GLtvtEaGKa").get.first
game_score.array_add_relation("opponents", player.pointer)
game_score.save
game_score["opponents"] #=> #<Parse::ArrayOp:0x007fbe98931508 @operation="AddRelation", @objects=[Player:GLtvtEaGKa]>
game_score["opponents"].objects.first #=> Player:GLtvtEaGKa
```

To remove an object from a relation, you can do:

```ruby
# TODO: This method is not yet implemented.
```

### Deleting Objects

To delete an object from the Parse Cloud, call `Parse::Object#parse_delete`. For example:

```ruby
game_score = Parse::Query.new("GameScore").eq("objectId", "5iEEIxM4MW").get.first
game_score.parse_delete
Parse::Query.new("GameScore").eq("objectId", "5iEEIxM4MW").get.length #=> 0
```

You can delete a single field from an object by using the `Parse::Object#delete_field` operation:

```ruby
# TODO: This method is not yet implemented.
```

### Batch Operations

To reduce the amount of time spent on network round trips, you can create, update, or delete several objects in one call, using the batch endpoint.

parse-ruby-client provides a "manual" way to construct Batch Operations, as well as some convenience methods. The commands are run in the order they are given. For example, to create a couple of GameScore objects using the "manual" style, use `Parse::Batch#add_request`. `#add_request` takes a `Hash` with `"method"`, `"path"`, and `"body"` keys that specify the HTTP command that would normally be used for that command. 

```ruby
batch = Parse::Batch.new
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

Because manually constructing `"path"` values is repetitive, you can use `Parse::Batch#create_object`, `Parse::Batch#update_object`, and `Parse::Batch#delete_object`. Each of these methods takes an instance of `Parse::Object` as the only argument. Then you just call `Parse::Batch#run!`.For example:

```ruby
# making a few GameScore objects
game_scores = [1, 2, 3, 4, 5].map do |i|
  gs = Parse::Object.new("GameScore")
  gs["score"] = "#{i}"
  gs
end

batch = Parse::Batch.new
game_scores.each do |gs|
  batch.create_object(gs)
end
batch.run!
```

The response from batch will be an `Array` with the same number of elements as the input list. Each item in the `Array` with be a `HAsh` with either the `"success"` or `"error"` field set. The value of success will be the normal response to the equivalent REST command:

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
game_score = Parse::Query.new("GameScore").tap do |q|
  g.greater_than("createdAt", Parse::Object.new(DateTime.now)) # query options explained in more detail later in this document
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
pointer = Parse::Pointer.new({"className => gameScore", "objectId" => "GeqPWJdNqp"})
```

Pointers to `user` objects have a `className` of `_User`. Prefixing with an underscore is forbidden for developer-defined classes and signifies the class is a special built-in.

#### Relation

The `Relation` type is used for many-to-many relations when the mobile uses `PFRelation` (iOS SDK) or `ParseRelation` (Android SDK) as a value. It has a `className` that is the class name of the target objects.

```ruby
# TODO: There is no Ruby object representation of this type, yet.
```

#### Future data types and namespacing

Though this is something parse-ruby-client will take care for you, it's worth noting:

When more data types are added, they will also be represented as hashes with a `__type` field set, so you may not use this field yourself on JSON objects.


## Queries

Queries are created like so:

```ruby
query = Parse::Query.new("GameScore")
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
query = Parse::Query.new("GameScore").eq("playerName", "Sean Plott")
```

Other constraint methods include:

<table>
  <tr>
    <td>`Parse::Query#less_than`</td>
    <td>Less Than</td>
  </tr>
  <tr>
    <td>`Parse::Query#less_eq`</td>
    <td>Less Than or Equal To</td>
  </tr>
  <tr>
    <td>`Parse::Query#greater_than`</td>
    <td>Greater Than</td>
  </tr>
  <tr>
    <td>`Parse::Query#greater_eq`</td>
    <td>Greater Than Or Equal To</td>
  </tr>
  <tr>
    <td>`Parse::Query#not_eq`</td>
    <td>Not Equal To</td>
  </tr>
  <tr>
    <td>`Parse::Query#value_in`</td>
    <td>Contained In</td>
  </tr>
  <tr>
    <td>`Parse::Query#value_not_in`</td>
    <td>Not Contained in</td>
  </tr>
  <tr>
    <td>`Parse::Query#exists`</td>
    <td>A value is set for the key</td>
  </tr>
  <tr>
    <td>`Parse::Query#select`</td>
    <td>TODO: `$select` not yet implemented. This matches a value for a key in the result of a different query</td>
  </tr> 
</table>

## Users

## Roles

## Files

## Push Notifications

## Installations

## Geopoints
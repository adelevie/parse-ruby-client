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

## Queries

## Users

## Roles

## Files

## Push Notifications

## Installations

## Geopoints
# Ruby Client for parse.com REST API

This file implements a simple Ruby client library for using Parse's REST API.
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

obj.parse_save
```

Load the data browser on parse.com and you should see your object!

## Resources

parse.com REST API documentation: https://parse.com/docs/rest

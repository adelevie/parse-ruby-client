require 'cgi'
require 'parse/error'

module Parse
  class Push
    attr_accessor :channels
    attr_accessor :channel
    attr_accessor :type
    attr_accessor :expiration_time_interval
    attr_accessor :expiration_time
    attr_accessor :data

    def initialize(data, channel = "")
      @data = data
      @channel = channel
    end

    def send
      uri   = Protocol.push_uri
      
      body = { :data => @data, :channel => @channel }
      body.merge({ :channels => @channels }) if @channels
      body.merge({ :expiration_time_interval => @expiration_time_interval }) if @expiration_time_interval
      body.merge({ :expiration_time => @expiration_time }) if @expiration_time 
      body.merge({ :type => @type }) if @type
      
      response = Parse.client.request uri, :post, body.to_json, nil
    end

  end

end
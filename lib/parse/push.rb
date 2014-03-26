# -*- encoding : utf-8 -*-
require 'cgi'
require 'parse/error'

module Parse
  class Push
    attr_accessor :channels
    attr_accessor :channel
    attr_accessor :where
    attr_accessor :type
    attr_accessor :expiration_time_interval
    attr_accessor :expiration_time
    attr_accessor :push_time
    attr_accessor :data

    def initialize(data, channel = "")
      @data = data
      @channel = channel
    end

    def save
      uri   = Protocol.push_uri

      body = { :data => @data, :channel => @channel }

      if @channels
        body.merge!({ :channels => @channels })
        body.delete :channel
      end

      if @where
        body.merge!({ :where => @where })
        body.delete :channel
      end

      body.merge!({ :expiration_interval => @expiration_time_interval }) if @expiration_time_interval
      body.merge!({ :expiration_time => @expiration_time }) if @expiration_time
      body.merge!({ :push_time => @push_time }) if @push_time
      body.merge!({ :type => @type }) if @type

      response = Parse.client.request uri, :post, body.to_json, nil
    end

  end

end

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

    def initialize(data, channel = "", client=nil)
      @data = data

      if !channel || channel.empty?
        # If no channel is specified, by setting "where" to an empty clause, a push is sent to all clients.
        @where = {}
      else 
        @channel = channel
      end

      @client = client || Parse.client
    end

    def save
      uri   = Protocol.push_uri

      body = { :data => @data, :channel => @channel }

      if @channels
        body.merge!({ :channels => @channels })
        body.delete :channel
      end


      if @type
        deviceType = { :deviceType => @type }
        if @where
           @where.merge!(deviceType)
        else
          @where = ({ :where => deviceType })
        end
      end

      if @where
        body.merge!({ :where => @where })
      end

      body.merge!({ :expiration_interval => @expiration_time_interval }) if @expiration_time_interval
      body.merge!({ :expiration_time => @expiration_time }) if @expiration_time
      body.merge!({ :push_time => @push_time }) if @push_time

      response = @client.request uri, :post, body.to_json, nil
    end

  end

end
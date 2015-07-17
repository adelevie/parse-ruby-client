# -*- encoding : utf-8 -*-
require 'cgi'
require 'parse/error'

module Parse
  class Push
    attr_accessor :channels
    attr_accessor :where
    attr_accessor :type
    attr_accessor :expiration_time_interval
    attr_accessor :expiration_time
    attr_accessor :push_time
    attr_accessor :data
    attr_accessor :client

    def initialize(data, channel = '', client = nil)
      @data = data

      # NOTE: if no channel is specified, by setting "where" to an empty clause
      #   a push is sent to all clients.
      if !channel || channel.empty?
        @where = {}
      else
        @channels = [channel]
      end

      @client = client || Parse.client
    end

    def save
      body = { data: @data }

      if @type
        if @where
          @where.merge!(deviceType: @type)
        else
          body.merge!(deviceType: @type)
        end
      end

      # NOTE: Parse does not support channels and where at the same time
      # so we make channels part of the query conditions
      if @channels
        if @where
          @where.merge!(channels: @channels)
        else
          body.merge!(channels: @channels)
        end
      end

      body.merge!(where: @where) if @where

      body.merge!(expiration_interval: @expiration_time_interval) if @expiration_time_interval
      body.merge!(expiration_time: @expiration_time) if @expiration_time
      body.merge!(push_time: @push_time) if @push_time

      @client.request Protocol.push_uri, :post, body.to_json
    end
  end
end

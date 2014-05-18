# -*- encoding : utf-8 -*-
## ----------------------------------------------------------------------
##
## Ruby client for parse.com
## A quick library for playing with parse.com's REST API for object storage.
## See https://parse.com/docs/rest for full documentation on the API.
##
## ----------------------------------------------------------------------
require 'rubygems'
require 'bundler/setup'

require 'faraday'
require 'faraday_middleware'
require 'faraday/better_retry'
require 'faraday/extended_parse_json'
require 'faraday/get_method_override'
require 'date'
require 'cgi'

cwd = Pathname(__FILE__).dirname
$:.unshift(cwd.to_s) unless $:.include?(cwd.to_s) || $:.include?(cwd.expand_path.to_s)

require 'parse/object'
require 'parse/query'
require 'parse/datatypes'
require 'parse/util'
require 'parse/protocol'
require 'parse/user'
require "parse/installation"
require 'parse/push'
require 'parse/cloud'
require 'parse/model'
require 'parse/batch'

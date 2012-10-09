## ----------------------------------------------------------------------
##
## Ruby client for parse.com
## A quick library for playing with parse.com's REST API for object storage.
## See https://parse.com/docs/rest for full documentation on the API.
##
## ----------------------------------------------------------------------
require "rubygems"
require "bundler/setup"

require 'json'
require 'patron'
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
require 'parse/push'
require 'parse/cloud'
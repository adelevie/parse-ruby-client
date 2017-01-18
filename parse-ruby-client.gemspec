# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'parse/version'

Gem::Specification.new do |spec|
  spec.name          = "parse-ruby-client"
  spec.version       = Parse::VERSION
  spec.authors       = ["Alan deLevie", "Adam Alpern", "David Brownman", "rhymes"]


  spec.summary       = %q{A simple Ruby client for the parse.com REST API}
  spec.homepage      = "http://github.com/adelevie/parse-ruby-client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1'

  spec.add_dependency 'faraday', '>= 0.9.2'
  spec.add_dependency 'faraday_middleware', '>= 0.9.2'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug' if RUBY_ENGINE == 'ruby'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'fasterer'
  spec.add_development_dependency 'json', '~> 1.8.3'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'minitest-focus'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'
end

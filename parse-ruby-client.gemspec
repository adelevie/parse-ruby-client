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
end

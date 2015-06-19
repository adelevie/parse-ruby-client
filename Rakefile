# encoding: utf-8
require 'rubygems'
require 'bundler'
require 'jeweler'
require 'rake/testtask'
require 'rdoc/task'

task default: :test

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end

Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = 'parse-ruby-client'
  gem.homepage = 'http://github.com/adelevie/parse-ruby-client'
  gem.license = 'MIT'
  gem.summary = %(A simple Ruby client for the parse.com REST API)
  gem.description = %(A simple Ruby client for the parse.com REST API)
  gem.email = 'adelevie@gmail.com'
  gem.authors = ['Alan deLevie', 'Adam Alpern']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

Rake::TestTask.new do |test|
  test.libs << 'test' # 'lib' << 'test'
  test.test_files = FileList['test/test_*.rb', 'test/middleware/*_test.rb']
  test.verbose = true
end

RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "parse-ruby-client #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

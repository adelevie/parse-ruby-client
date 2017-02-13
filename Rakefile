# encoding: utf-8
require 'dotenv/load'
require 'bundler/gem_tasks'
require 'rake/testtask'

task default: :test

Rake::TestTask.new do |test|
  test.libs << 'lib'
  test.libs << 'test'
  test.test_files = FileList['test/test_*.rb', 'test/middleware/*_test.rb']
end

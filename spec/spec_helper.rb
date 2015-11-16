require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
require "webrat"
require "byebug"
require "pry"
require File.join(File.dirname(__FILE__), '..','app')

set :environment, :test

Webrat.configure do |config|
  config.mode = :rack
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Webrat::Methods
  config.include Webrat::Matchers
end

SafeCache.flush

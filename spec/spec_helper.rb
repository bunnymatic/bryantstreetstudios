require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
require 'mocha'
require 'rspec_hpricot_matchers'
require File.join(File.dirname(__FILE__), '..','app')

set :environment, :test

RSpec.configure do |config|
  config.include(RspecHpricotMatchers)
end

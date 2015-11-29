require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
require "capybara"
require "byebug"
require "pry"
require "vcr"
require File.join(File.dirname(__FILE__), '..','app')

set :environment, :test

# Webrat.configure do |config|
#   config.mode = :rack
# end

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = 'spec/vcr-cassettes'
  config.configure_rspec_metadata!
  # config.allow_http_connections_when_no_cassette = true
end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Capybara::DSL

  config.raise_errors_for_deprecations!
end

SafeCache.flush

Capybara.app = BryantStreetStudios

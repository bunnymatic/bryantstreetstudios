require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'rspec'
require "capybara/dsl"
require "byebug"
require "pry"
require "vcr"
require File.join(File.dirname(__FILE__), '..','app')

Dir[File.join(File.dirname(__FILE__),"{support}/**/*.rb")].each do |file|
  require file
end

set :environment, :test

# Webrat.configure do |config|
#   config.mode = :rack
# end

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.include Capybara::DSL

  config.raise_errors_for_deprecations!
end

SafeCache.flush

Capybara.app = BryantStreetStudios

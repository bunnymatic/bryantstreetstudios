source 'http://rubygems.org'
ruby '2.1.5'

gem 'sinatra'
gem 'sinatra-contrib' 
gem 'sinatra-logger'
gem 'sinatra-static-assets'
gem 'thin'
gem 'haml'
gem 'sass'
gem "rake"
gem 'memcachier'
gem 'dalli'
gem 'rest-client'
gem 'rdiscount'
gem 'faye'
gem 'eventmachine'
gem 'kgio'
gem "datamapper", '~> 1.2.0'
gem "dm-aggregates", "~> 1.2.0"
gem "dm-postgres-adapter", "~> 1.2.0"
gem 'oj'

# krobertson's needs a few patches for heroku/s3 tiein
gem "dm-paperclip", :git => 'https://github.com/krobertson/dm-paperclip.git'
gem 'aws-s3'

gem 'pg'


group :test, :development do
  gem 'fakeweb'
  gem "rspec"
  gem 'webrat'
  gem "rack-test"
  gem "mime-types"
  gem "jasmine"
end

source 'http://rubygems.org'
ruby '2.1.5'
# careful with >2.3 issues with pg http://stackoverflow.com/questions/27862098/problems-with-postgres-and-unicorn-server/27995428#27995428

gem 'sinatra'
gem 'sinatra-contrib'
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

gem "aws-sdk"
gem "dm-paperclip-s3", :git => 'https://github.com/krzak/dm-paperclip-s3.git'

gem 'pg'

group :test, :development do
  gem 'pry-byebug'
  gem "rspec"
  gem "capybara"
  gem "launchy"
  gem "mime-types"
  gem "jasmine"
  gem "tux"
  gem "vcr"
  gem "webmock"
end

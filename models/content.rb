require 'sinatra'
require 'data_mapper'

class ContentResource
  include DataMapper::Resource
  property :id, Serial
  property :page, String, :length => 255
  property :section, String, :length => 255, :default => '', :unique => :page
  property :body, String, :length => 4048

  validates_presence_of :page
end


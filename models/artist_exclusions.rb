require 'sinatra'
require 'data_mapper'

class ArtistExclusion
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 255
  property :case_insensitive, Boolean, :default => true
  validates_presence_of :name
  validates_length_of :name, :minimum => 4
end

DataMapper.finalize

require 'sinatra'
require 'data_mapper'

class ArtistExclusion
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :length => 255
  property :case_insensitive, Boolean, :default => true
  validates_presence_of :name
  validates_length_of :name, :minimum => 4

  def regex
    Regexp.new(name.strip.gsub(/\s+/,'\s+'), :options => (case_insensitive ? 2 : 0))
  end

  def match *args
    regex.send(:match, *args)
  end

end

DataMapper.finalize

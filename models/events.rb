require 'sinatra'
require 'data_mapper'
require 'dm-paperclip'

class EventResource
  include Paperclip::Resource
  include DataMapper::Resource
  property :id, Serial
  property :title, String, :length => 255
  property :description, String, :length => 2048
  property :address, String, :length => 255
  property :starttime, DateTime
  property :endtime, DateTime
  property :url, String, :length => 255

  validates_presence_of :starttime
  validates_presence_of :title

  has_attached_file :picture,
  :storage => :s3,
  :path => "/images/:style/:filename",
  :s3_credentials => {
    :access_key_id => ENV['S3_ACCESS_KEY'],
    :secret_access_key => ENV['S3_SECRET'],
    :bucket => ENV['S3_BUCKET'] || '1890bryant'
  },
  :styles => { 
    :display => { :geometry => '350x600>' }
  }
  
  def map_link
    if address.present?
      "http://maps.google.com/maps?q=%s" % URI.escape(address, /[[:punct:][:space:]]/)
    end
  end
  
end

class Object
  def empty?
    (self == nil) || (self.respond_to?(:length) && self.length == 0)
  end
  def present?
    !empty?
  end
end


require 'sinatra'
require 'data_mapper'
require 'dm-paperclip'

class PictureResource

  include DataMapper::Resource
  include Paperclip::Resource
  
  property :id, Serial

  has_attached_file :picture,
  :storage => :s3,
  :path => "/pictures/:style/:filename",
  :s3_credentials => {
    :access_key_id => ENV['S3_ACCESS_KEY'],
    :secret_access_key => ENV['S3_SECRET'],
    :bucket => ENV['S3_BUCKET'] || '1890bryant'
  },
  :styles => { 
    :display => { :geometry => '350x600>' }
  }

  def as_json(options = {})
    json = super
    json.merge({ :url => {
                   :original => self.file(:original),
                   :display => self.file(:display) 
                 }
               })
  end
end

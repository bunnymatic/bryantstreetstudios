require 'dalli'
require 'ostruct'

class Medium

  def initialize(model)
    @model = model
  end

  def id
    @model['id']
  end

  def name
    @model['name']
  end

end

class Mediums
  include Enumerable

  @@media = nil

  def self.find(_id)
    if !_id
      return nil
    end
    media[_id.to_i]
  end

  def self.each &block
    media.each{|mid, m| block.call(mid, m)}
  end

  private
  def media
    self.class.media
  end

  def self.media
    conf = BryantStreetStudios.settings
    media_list = SafeCache.get('media')
    if !media_list || media_list.empty?
      begin
        url = "%s/media.json" % conf.mau_api_url
        media_list = MAU::RestClient.get_json url
      rescue Exception => ex
        puts "ERROR: Unable to connect to #{url}"
        puts "Exception: #{ex.to_s}"
      end
      SafeCache.set('media', media_list) unless (!media_list|| media_list.empty?)
    end
    @@media = Hash[media_list.map{|m| entry = Medium.new(m['medium']); [entry.id, entry]}]
  end

end

require 'dalli'
require 'rest_client'
require 'ostruct'

class Artists
  ALLOWED_KEYS = ["firstname", "lastname"]

  include Enumerable

  @@artists = nil

  def initialize
    conf = BryantStreetStudios.config
    s = Studio.new
    artists = BryantStreetStudios.cache.get('artists')
    if !artists || artists.empty?
      all_artists = []
      begin 
        url = "%s/artists" % conf.mau_api_url
        resp = RestClient.get url
        all_artists = JSON.parse(resp.body)
      rescue Exception => ex
        puts "ERROR: Unable to connect to #{url}"
        puts "Exception: #{ex.to_s}"
      end
      artists = all_artists.map{|artist| artist['artist']}.select{|a| a['studio_id'].to_i == s.id.to_i}
      BryantStreetStudios.cache.set('artists', artists) unless (!artists || artists.empty?)
    end
    @@artists = artists.map{|a| OpenStruct.new(a)}
  end

  def each &block
    @@artists.each{|a| block.call(a)}
  end

end

require 'dalli'
require 'rest_client'
require 'ostruct'

class Artists
  ALLOWED_KEYS = ["firstname", "lastname"]

  include Enumerable

  @@artists = nil

  def initialize
    conf = BryantStreetStudios.settings
    s = Studio.new
    artists = SafeCache.get('artists')
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
      # add/update art_piece filenames
      artists.each do |a|
        a['art_pieces'].each do |ap|
          fname = ap['filename']
          furl = "%s/%s" % [conf.mau_web_url, fname.gsub(/^public\//, '')]
          ap['thumb'] = furl.gsub(/(.*)\/([^\/]*$)/, '\1/t_\2')
          ap['small'] = furl.gsub(/(.*)\/([^\/]*$)/, '\1/s_\2')
          ap['medium'] = furl.gsub(/(.*)\/([^\/]*$)/, '\1/m_\2')
          ap['large'] = furl.gsub(/(.*)\/([^\/]*$)/, '\1/l_\2')
        end
      end
      SafeCache.set('artists', artists) unless (!artists || artists.empty?)
    end
    @@artists = artists.map{|a| OpenStruct.new(a)}
  end

  def each &block
    @@artists.each{|a| block.call(a)}
  end

end

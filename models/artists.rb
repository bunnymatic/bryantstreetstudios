require 'dalli'
require 'rest_client'
require 'ostruct'
require 'uri'

class Artist < OpenStruct; 

  def fullname 
    firstname + ' ' + lastname
  end

  def website
    url
  end

  def self.make_link(uri, opts = {}, &block)
    if ! (/https?\:\/\// =~ uri)
      uri = 'http://' + uri
    end
    buf = "<a href='#{uri}' "
    buf << opts.map{ |k,v| "#{k}=\'#{v}'"}.join(" ")
    buf << ">"
    buf << (block ? block.call : uri.gsub(/https?:\/\//, ''))
    buf << "</a>"
  end
end



class Artists
  ALLOWED_KEYS = ["firstname", "lastname"]

  include Enumerable

  @@artists = nil

  def self.find(_id) 
    if !_id
      return nil
    end
    artists[_id.to_i]
  end

  def length
    artists.length
  end
  alias :count :length
  alias :size :length

  def each &block
    artists.each{|aid,a| block.call(aid,a)}
  end

  private
  def artists
    self.class.artists
  end

  def self.artists
    s = Studio.new
    conf = BryantStreetStudios.settings
    artist_list = SafeCache.get('artists')
    if !artist_list || artist_list.empty?
      all_artists = []
      begin 
        url = "%s/artists" % conf.mau_api_url
        resp = RestClient.get url
        all_artists = Oj.load(resp.body)
      rescue Exception => ex
        puts "ERROR: Unable to connect to #{url}"
        puts "Exception: #{ex.to_s}"
      end
      artist_list = all_artists.map{|artist| artist['artist']}.select{|a| a['studio_id'].to_i == s.id.to_i}
      # add/update art_piece filenames
      artist_list.each do |a|
        a['art_pieces'].each do |ap|
          if (ap['medium_id'] && ap['medium_id'].to_i != 0) 
            m = Mediums.find(ap['medium_id'].to_i) 
            ap['media'] = m.name if m
          end
          fname = ap['filename']
          furl = ("%s/%s" % [conf.mau_web_url, fname.gsub(/^public\//, '')])
          ap['thumb'] = furl.gsub(/(.*)\/([^\/]*$)/, '\1/t_\2')
          ap['small'] = furl.gsub(/(.*)\/([^\/]*$)/, '\1/s_\2')
          ap['medium'] = furl.gsub(/(.*)\/([^\/]*$)/, '\1/m_\2')
          ap['large'] = furl.gsub(/(.*)\/([^\/]*$)/, '\1/l_\2')
        end
      end
      SafeCache.set('artists', artist_list) unless (!artist_list || artist_list.empty?)
    end
    @@artists = Hash[artist_list.map{|a| entry = Artist.new(a); [entry.id, entry]}]
  end

end

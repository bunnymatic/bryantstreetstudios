require 'dalli'
require 'rest_client'
require 'ostruct'
require 'uri'

class Artist

  attr_reader :model

  def initialize(model_data)
    @model = model_data
  end

  def id
    @model['id']
  end

  def name
    @model['name']
  end

  def firstname
    @model['firstname']
  end

  def lastname
    @model['lastname']
  end

  def fullname
    [firstname, lastname].join " "
  end

  def website
    @model['url']
  end

  def bio
    @model['bio']
  end

  def email
    @model['email']
  end

  def facebook
    @model['facebook']
  end

  def twitter
    @model['twitter']
  end

  def myspace
    @model['myspace']
  end

  def pinterest
    @model['pinterest']
  end

  def blog
    @model['blog']
  end

  def art_pieces
    @model['art_pieces'].map { |art| ArtPiece.new(art) }
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
      SafeCache.set('artists', artist_list) unless (!artist_list || artist_list.empty?)
    end
    @@artists = Hash[artist_list.map{|a| entry = Artist.new(a); [entry.id, entry]}]
  end

end

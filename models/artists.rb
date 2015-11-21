require 'dalli'
require 'uri'
require_relative './mau_model'

class Artist < MauModel

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

  def self.fetch(id)
    key = "artist_#{id}"
    artist = SafeCache.get(key)
    unless artist
      artist = get_json("artists/#{id}.json")
      if artist.has_key? 'artist'
        artist = artist.fetch('artist')
      end
      SafeCache.set(key, artist) if artist
    end
    puts artist
    Artist.new(artist)
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

  def art_pieces
    @model['art_pieces'][0..3].map do |item|
      ArtPiece.fetch(self, item['id'])
    end
  end
end

class Artists < MauModel
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
    artists = SafeCache.get('artists')
    if !artists || artists.empty?

      artists = get_json( "/artists.json?studio=#{s.slug}" )
      if artists.has_key? 'artists'
        artists = artists['artists']
      end
      SafeCache.set('artists', artists) unless (!artists || artists.empty?)
    end
    @@artists = Hash[artists.map{|a| entry = Artist.new(a); [entry.id, entry]}]
  end

end

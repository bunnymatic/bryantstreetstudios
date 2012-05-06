# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/logger'
require 'sinatra/static_assets'
require 'haml'
require 'uri'
require 'json'
require 'dalli'
require 'ostruct'
require 'yaml'

class String
  def truncate(len = 40, postfix = '...')
    return self if length <= len - postfix.length
    new_len = len - postfix.length - 1
    self[0..new_len] + postfix
  end
end

class BryantStreetStudios < Sinatra::Base

  set :environment, :production
  set :logging, true
  set :root, File.dirname(__FILE__)

  register Sinatra::StaticAssets
  register Sinatra::Logger 

  APP_ROOT = root
  TIME_FORMAT = "%b %e %Y %-I:%M%p"

  @@config = nil

  def self.configure opts={}
    conf = File.join(root, 'config','config.yml')
    if File.exists? conf
      c = YAML::load(File.read(conf))
    end
    @@config = OpenStruct.new(c.merge(opts))
  end

  def self.config 
    @@config || self.configure
  end

  def self.cache
    @@cache ||= Dalli::Client.new('localhost:11211', :expires_in => 24 * 60 * 60)
  end

  helpers do
    
    BASE_TITLE = '1890 Bryant Street Studios'
    
    def make_title *args
      [BASE_TITLE, *args].flatten.compact.join(" : ")
    end

    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end
    
    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['jennymey', 'jonnlovesjenn']
    end

  end

  set :haml, :format => :html5

  get '/' do
    @title = make_title
    @studio = Studio.new
    @artists = Artists.new
    @current_section = 'home'
    haml :index
  end

  get '/artists' do
    @title = make_title 'Artists'
    @artists = Artists.new
    @current_section = 'artists'
    haml :artists
  end

  # other pages with simple content
  [:contact, :press, :events].each do |page|
    get "/#{page}" do
      @current_section = page.to_s
      haml page
    end
  end

end


Dir[File.join(File.dirname(__FILE__),"{lib,models}/**/*.rb")].each do |file|
  require file
end


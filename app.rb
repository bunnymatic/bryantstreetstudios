# -*- coding: utf-8 -*-
require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/logger'
require 'sinatra/static_assets'
require 'haml'
require 'uri'
require 'json'
require 'dalli'
require 'ostruct'
require 'yaml'
require 'data_mapper'
require 'dm-paperclip'

LETTERS_PLUS_SPACE =  []
('a'..'z').each {|ltr| LETTERS_PLUS_SPACE << ltr}
('A'..'Z').each {|ltr| LETTERS_PLUS_SPACE << ltr}

def gen_random_string(len=8)
  numchars = LETTERS_PLUS_SPACE.length
  (0..len).map{ LETTERS_PLUS_SPACE[rand(numchars)] }.join
end

class String
  def truncate(len = 40, postfix = '...')
    return self if length <= len - postfix.length
    new_len = len - postfix.length - 1
    self[0..new_len] + postfix
  end
end

class BryantStreetStudios < Sinatra::Base

  set :environments, %w{development test production staging}
  set :environment, :development
  set :logging, true
  set :root, File.dirname(__FILE__)

  register Sinatra::ConfigFile
  register Sinatra::StaticAssets
  register Sinatra::Logger 

  DataMapper::setup(:default, ENV['DATABASE_URL'] || "postgres://bryant:bryant@localhost/bryant")

  APP_ROOT = root
  TIME_FORMAT = "%b %e %Y %-I:%M%p"

  config_file File.join( [root, 'config', 'config.yml'] )

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
      user = ENV['1890_ADMIN_USER'] || gen_random_string
      pass = ENV['1890_ADMIN_PASS'] || gen_random_string
      #puts "User/Pass: #{user} #{pass}"
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [user,pass]
    end

  end

  set :haml, :format => :html5

  get '/' do
    @title = make_title
    @studio = Studio.new
    @artists = Artists.new
    @current_section = 'home'
    @breadcrumb = BreadCrumbs.new([])
    haml :index
  end

  get '/artists' do
    @title = make_title 'Artists'
    @artists = Artists.new
    @current_section = 'artists'
    @breadcrumb = BreadCrumbs.new([:home, :artists])
    haml :artists
  end

  get '/artists/:id' do
    @title = make_title 'Artist'
    @artist = Artists.find(params[:id])
    @current_section = 'artist'
    @breadcrumb = BreadCrumbs.new([:home, :artists, @artist.fullname])
    haml :artist
  end

  # other pages with simple content
  [:contact, :press, :events].each do |page|
    get "/#{page}" do
      @current_section = page.to_s
      @breadcrumb = BreadCrumbs.new([:home, page])
      haml page
    end
  end

  get '/cacheflush' do
    begin
      SafeCache.flush
    rescue Exception => ex
      puts '*** fail'
      raise
    end
    redirect '/'
  end
    
end


Dir[File.join(File.dirname(__FILE__),"{lib,models}/**/*.rb")].each do |file|
  require file
end


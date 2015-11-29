# -*- coding: utf-8 -*-
require 'bundler/setup'
require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/static_assets'
require 'haml'
require 'uri'
require 'json'
require 'dalli'
require 'ostruct'
require 'yaml'
require 'dm-core'
require 'dm-postgres-adapter'
require 'dm-paperclip'
require 'rdiscount'
require 'thin'
require 'faye'
require 'eventmachine'
require 'oj'
require './lib/string_generators'

class BryantStreetStudios < Sinatra::Base

  use Rack::Session::Pool

  set :environments, %w{development test production staging}
  set :environment, ENV['RACK_ENV'] || :development
  set :root, File.dirname(__FILE__)
  set :logging, true

  register Sinatra::ConfigFile
  register Sinatra::StaticAssets

  configure :production, :development do
    enable :logging
  end

  APP_ROOT = root
  TIME_FORMAT = "%b %e %Y %-I:%M%p"

  config_file File.join( [root, 'config', 'config.yml'] )

  # fetch from env or config
  set :dburl, ENV.fetch('DATABASE_URL', settings.database_url)
  set :auth_user, ENV.fetch('1890_ADMIN_USER', settings.auth_user || gen_random_string)
  set :auth_pass, ENV.fetch('1890_ADMIN_PASS', settings.auth_pass || gen_random_string)
  set :mau_api_key, ENV.fetch('MAU_API_KEY', 'whatever')
  set :mau_studio_id, ENV.fetch('MAU_STUDIO_ID', '1890-bryant-street-studios')
  set :mau_api_url, ENV.fetch("MAU_API_URL", settings.mau_api_url)

  DataMapper::setup(:default, dburl)

  helpers do

    BASE_TITLE = '1890 Bryant Street Studios'

    def markdown_content(md)
      RDiscount.new(md || '').to_html
    end

    def make_title *args
      [BASE_TITLE, *args].flatten.compact.join(" : ")
    end

    def protected!
      begin
        unless authorized?
          response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
          throw(:halt, [401, "Not authorized\n"])
        end
      rescue Exception => ex
        puts "EX", ex
      end
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      credentials = [BryantStreetStudios.auth_user, BryantStreetStudios.auth_pass]
      return (@auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == credentials)
    end

    def admin_haml(template, options={})
      haml(template.to_sym, options.merge(:layout => 'admin/layout'.to_sym))
    end

  end

  set :haml, :format => :html5

  # front page
  get '/' do
    @title = make_title
    @studio = Studio.new
    @current_section = 'home'
    @breadcrumb = BreadCrumbs.new([])
    announcement = ContentResource.first(:page => 'home', :section => 'announcement')
    @announcement = announcement.body if announcement
    haml :index
  end

  get '/artists' do
    @title = make_title 'Artists'
    artists = Artists.new
    exclusions = ArtistExclusion.all
    @artists = []
    artists.each do |aid, a|
      @artists << a unless exclusions.any?{|ex| ex.match a.fullname}
    end
    @artists.sort_by!{|a| a.lastname.downcase}

    @current_section = 'artists'
    @breadcrumb = BreadCrumbs.new([:home, :artists])
    haml :artists
  end

  get '/artists/:id' do
    @artist = Artists.find(params[:id].to_i)
    @current_section = 'artist'
    @breadcrumb = BreadCrumbs.new([:home, :artists, @artist.fullname])
    @title = make_title 'Artist', @artist.fullname
    haml :artist
  end

  # other pages with simple content
  [:contact, :events].each do |page|
    get "/#{page}" do
      @current_section = page.to_s
      @breadcrumb = BreadCrumbs.new([:home, page])
      content = ContentResource.first(:page => page)
      @content_body = (content ? content.body : 'Nothing to see here.')
      haml page
    end
  end

  ###### admin endpoints
  get '/admin' do
    protected!
    @current_section = 'dashboard'
    @artists = Artists.new
    admin_haml 'admin/dashboard'
  end

  ## pictures
  get '/admin/pictures' do
    protected!
    @current_section = 'admin_pictures'
    @images = PictureResource.all.sort{|a,b| b.id <=> a.id}
    admin_haml 'admin/pictures'
  end

  ### new
  post '/admin/picture' do
    protected!
    img = PictureResource.new(:picture => params['file'])
    halt "There were issues with your upload..." unless img.save
    redirect '/admin/pictures'
  end

  ### delete
  get '/admin/picture/:id/delete' do
    protected!
    img = PictureResource.get(params['id'].to_i)
    if img
      img.destroy
    end
    redirect '/admin/pictures'
  end


  ## content blocks
  ### show all
  get '/admin/content_blocks' do
    protected!
    @current_section = 'admin_content_blocks'
    @content_blocks = (ContentResource.all || [])
    admin_haml 'admin/content_blocks'
  end

  # new
  get '/admin/content_block' do
    protected!
    @current_section = 'admin_content_block'
    @content_block = ContentResource.new
    admin_haml 'admin/content_block'
  end

  ### show/edit
  get '/admin/content_block/:id' do
    protected!
    @current_section = 'admin_content_block'
    @content_block = ContentResource.get(params['id'].to_i)
    admin_haml 'admin/content_block'
  end

  ### update
  post '/admin/content_block' do
    protected!
    _id = params['content_block']['id']
    @content_block = (_id.present? ? ContentResource.get(_id.to_i) : ContentResource.new)
    @content_block.attributes = params['content_block']
    unless @content_block.save
      admin_haml 'admin/content_block'
    else
      redirect '/admin/content_blocks'
    end
  end

  ### delete
  get '/admin/content_block/:id/delete' do
    protected!
    r = ContentResource.get(params['id'].to_i)
    r.destroy if r
    redirect '/admin/content_blocks'
  end

  ### artist_exclusions
  get '/admin/exclusions' do
    protected!
    @current_section = 'exclusions'
    @exclusions = ArtistExclusion.all
    @artists = Artists.new.map{|aid,a| a}

    admin_haml 'admin/exclusions'
  end

  ### new
  post '/admin/exclusion' do
    protected!
    if params['exclusion'] && params['exclusion'].has_key?('case_insensitive')
      params['exclusion']['case_insensitive'] = params['exclusion']['case_insensitive'].to_bool
    end
    a = ArtistExclusion.create(params['exclusion'])
    redirect 'admin/exclusions'
  end

  ### artist_exclusions
  get '/admin/exclusion/:id/delete' do
    protected!
    ae = ArtistExclusion.get(params['id'].to_i)
    ae.destroy if ae
    redirect '/admin/exclusions'
  end


  ## other

  ### preview markdown do
  post '/admin/markdown' do
    protected!
    markdown_content(params[:data])
  end

  get '/admin/cacheflush' do
    protected!
    begin
      SafeCache.flush
    rescue Exception => ex
      puts '*** fail' + ex.to_s
      raise
    end
    redirect '/'
  end


  get '/admin/env' do
    @current_section = 'environment'
    protected!
    @env = ENV
    @user = BryantStreetStudios.auth_user
    @pass = BryantStreetStudios.auth_pass
    @sinatra_mode = BryantStreetStudios.environment
    admin_haml 'admin/env'
  end

end

Dir[File.join(File.dirname(__FILE__),"{lib,models}/**/*.rb")].each do |file|
  require file
end
require File.join(File.dirname(__FILE__),"models/models.rb")

DataMapper.finalize
DataMapper.auto_upgrade!

EM.next_tick {


  FAYE_SERVER_URL = ENV['FAYE_SERVER_URL'] || 'http://localhost:3030/maumessages'; #mau-messages.herokuapp.com:80/maumessages';
  SUBSCRIBER_TOKEN = ENV['FAYE_SUBSCRIBER_TOKEN'] || 'whatevs_yo'

  FAYE_SERVER_URL = 'http://mau-messages.herokuapp.com:80/maumessages'
  SUBSCRIBER_TOKEN = 'gomakesomeart'.reverse

  class ClientAuth
    def outgoing(msg,cb)
      if msg['channel'] == '/meta/subscribe'
        msg['ext'] ||= {}
        msg['ext']['subscriberToken'] = SUBSCRIBER_TOKEN
      end
      cb.call msg
    end
  end

  begin
    client = Faye::Client.new(FAYE_SERVER_URL)
    client.add_extension(ClientAuth.new)
    client.subscribe('/artists/**') do |msg|
      puts msg.inspect
    end
  rescue Exception => ex
    p  "Faye server failed: ", ex
  end
}

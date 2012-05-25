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

class BryantStreetStudios < Sinatra::Base

  set :environments, %w{development test production staging}
  set :environment, ENV['RACK_ENV'] || :development
  set :logging, true
  set :root, File.dirname(__FILE__)

  register Sinatra::ConfigFile
  register Sinatra::StaticAssets
  register Sinatra::Logger 

  APP_ROOT = root
  TIME_FORMAT = "%b %e %Y %-I:%M%p"

  config_file File.join( [root, 'config', 'config.yml'] )

  DataMapper::setup(:default, ENV['DATABASE_URL'] || settings.database_url)

  # get user/pass from ENV (for heroku) or our config file, or generate something random as a fallback
  set :auth_user, ENV['1890_ADMIN_USER'] || settings.auth_user || gen_random_string
  set :auth_pass, ENV['1890_ADMIN_PASS'] || settings.auth_pass || gen_random_string

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
      #puts "User/Pass: #{user} #{pass}"
      user = BryantStreetStudios.auth_user
      pass = BryantStreetStudios.auth_pass
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [user,pass]
    end

    def admin_haml(template, options={}) 
      haml(template, options.merge(:layout => :'admin/layout')) 
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
  [:contact, :events].each do |page|
    get "/#{page}" do
      @current_section = page.to_s
      @breadcrumb = BreadCrumbs.new([:home, page])
      haml page
    end
  end

  ###### admin endpoints
  
  ## events
  get '/admin/events' do
    protected!
    @current_section = 'admin_events'
    @events = (EventResource.all || [])
    admin_haml 'admin/events'
  end

  post '/admin/events' do
    protected!
    redirect '/admin/events'
  end

  post '/admin/events/update_attr' do
    protected!
  end

  ## other
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


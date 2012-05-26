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
require 'rdiscount'

class BryantStreetStudios < Sinatra::Base

  use Rack::Session::Pool

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

  # fetch from env or config
  set :dburl, ENV['DATABASE_URL'] || settings.database_url
  set :auth_user, ENV['1890_ADMIN_USER'] || settings.auth_user || gen_random_string
  set :auth_pass, ENV['1890_ADMIN_PASS'] || settings.auth_pass || gen_random_string
  
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
      content = ContentResource.first(:page => page)
      @content_body = (content ? content.body : 'Nothing to see here.')
      haml page
    end
  end

  ###### admin endpoints
  get '/admin' do
    protected!
    @current_section = 'admin'
    admin_haml 'admin/dashboard'
  end

  ## pictures
  get '/admin/pictures' do
    protected!
    @title = "Pictures"
    @images = ImageResource.all.sort{|a,b| b.id <=> a.id}
    admin_haml 'admin/pictures'
  end

  get '/admin/pictures/del/:id' do
    protected!
    img = ImageResource.get(params['id'])
    if img
      img.destroy
    end
    redirect '/admin/pictures'
  end

  get '/admin/pictures/upload' do
    protected!
    admin_haml 'admin/pictures_upload'
  end

  post '/admin/pictures/upload' do
    protected!
    img = ImageResource.new(:file => params['file'])
    halt "There were issues with your upload..." unless img.save
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
    @content_block = ContentResource.new
    admin_haml 'admin/content_block'
  end

  ### show/edit
  get '/admin/content_block/:id' do
    protected!
    @content_block = ContentResource.get(params['id'])
    admin_haml 'admin/content_block'
  end

  ### update
  post '/admin/content_block' do
    protected!
    _id = params['content_block']['id']
    @content_block = (_id.present? ? ContentResource.get(_id) : ContentResource.new)
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
    r = ContentResource.get(params['id'])
    r.destroy if r
    redirect '/admin/content_blocks'
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
DataMapper.finalize
DataMapper.auto_upgrade!

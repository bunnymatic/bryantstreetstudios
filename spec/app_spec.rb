require File.join(File.dirname(__FILE__),'spec_helper')
require File.join(File.dirname(__FILE__),'mockmau')

Dir[File.join(File.dirname(__FILE__),'..',"{lib,models}/**/*.rb")].each do |file|
  require file
end
DataMapper.auto_migrate!

require 'mime/types'

describe BryantStreetStudios do
  include Rack::Test::Methods

  def login_as_admin
    authorize 'whatever','whatever'
  end

  def app
    @app ||= BryantStreetStudios
  end

  def setup_fixtures
    ContentResource.all.map(&:destroy)
    ContentResource.create({:page => 'events', :section => 's', :body => "## Here's what we've got planned\n\n* this\n*that\n\n"})
  end

  # mock connection to mau setup with fakeweb in mockmau
  context 'Protected endpoints:' do
    [ :pictures, :content_block, :content_blocks, :env, :exclusions ].each do |endpoint|
      describe 'unauthorized GET' do
        it "/admin/#{endpoint} responds error" do
          get "/admin/"+endpoint.to_s
          last_response.status.should == 401
        end
      end
    end
    [ '/admin/picture'].each do |endpoint|
      describe 'unauthorized POST' do
        it "#{endpoint} responds error" do
          post *endpoint
          last_response.status.should == 401
        end
      end
    end
  end
  
  describe '#index' do
    before do
      # putting the get here doesn't seem to work
    end
    it 'should return success' do
      get '/'
      response.should be_ok
    end
  end

  describe '#artists' do
    before do
      # putting the get here doesn't seem to work
    end
    it 'should return success' do
      get '/artists'
      response.should be_ok
    end
    it 'should list the artists in the sidebar' do
      get '/artists'
      response_body.should have_selector('.sidebar li.artist a .name', :count => 8)
    end
    it 'should list the artists with art pieces in the content' do
      get '/artists'
      response_body.should have_selector('.content li.thumb a .img', :count => 7)
      response_body.should have_selector('.content li.thumb a .name', :count => 7)
    end
    it 'artists are listed alphabetically' do
      get '/artists'
      response_body.should have_selector('.content li.thumb .name') do |names|
        names[0].should contain 'aabbcc'
        names.last.should contain 'Martha'
      end
      response_body.should have_selector('.sidebar li.artist .name') do |names|
        names[0].should contain 'aabbcc'
        names.last.should contain 'Martha'
      end
    end
      
  end

  describe '#artists/:id' do
    before do
      # putting the get here doesn't seem to work
    end
    it 'should return success' do
      get '/artists/10'
      response.should be_ok
    end
    it 'shows the artist\'s name in the title' do
      get '/artists/10'
      response_body.should have_selector 'title' do |t|
        t.should contain 'Rhiannon Alpers'
      end
    end
  end

  describe '#events' do
    before do
      # putting the get here doesn't seem to work
      setup_fixtures
    end
    it 'should return success' do
      get '/events'
      response.should be_ok
    end
    it 'should render the content block for events' do
      get '/events'
      response_body.should have_selector 'h2' do |chunk|
        chunk.should contain 'Here\'s what we\'ve got planned'
      end
    end
  end

  describe '#contact' do
    before do
      # putting the get here doesn't seem to work
    end
    it 'should return success' do
      get '/contact'
      response.should be_ok
    end
  end
  
end

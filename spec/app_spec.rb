require File.join(File.dirname(__FILE__),'spec_helper')
require File.join(File.dirname(__FILE__),'mockmau')

Dir[File.join(File.dirname(__FILE__),'..',"{lib,models}/**/*.rb")].each do |file|
  require file
end
DataMapper.finalize

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
    [ :pictures, :content_blocks, :env ].each do |endpoint|
      describe 'unauthorized GET' do
        it "/admin/#{endpoint} responds error" do
          get "/admin/"+endpoint.to_s
          last_response.status.should == 401
        end
      end
      describe 'authorized GET' do
        it "/admin/#{endpoint} responds ok" do
          login_as_admin
          get "/admin/"+endpoint.to_s
          last_response.should be_ok
        end
        it "#{endpoint} uses the admin layout" do
          login_as_admin
          get "/admin/"+endpoint.to_s
          response_body.should have_selector('nav.admin') do |admin_section|
            admin_section.should have_selector('li') do |tag|
              tag.should have_selector('a', :count => 4) do |lnks|
                lnks[0]['href'].should == '/'
                lnks[0].should contain 'main site'
                lnks[1]['href'].should == '/admin/pictures'
                lnks[1].should contain 'pictures'
                lnks[2]['href'].should == '/admin/content_blocks'
                lnks[2].should contain 'content blocks'
                lnks[3]['href'].should == '/admin/env'
                lnks[3].should contain 'env'
              end
            end
          end
        end
      end
    end
    [ ['/admin/content_block', '/admin/pictures/upload']].each do |endpoint|
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
    it 'should list the artists in the content' do
      get '/artists'
      response_body.should have_selector('.content li.thumb a .img', :count => 8)
      response_body.should have_selector('.content li.thumb a .name', :count => 8)
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

  ########## Admin endpoints
  describe '#admin/content_blocks' do
    before do
      login_as_admin
    end
    it 'shows a list of content blocks' do
      setup_fixtures
      get '/admin/content_blocks'
      response_body.should have_selector 'tbody tr', :count => ContentResource.count
    end
    
    it 'shows the expected fields: page, section, body' do
      pending "move this to the edit page when we have one"
      get '/admin/content_blocks'
      fields = [:page, :section, :body]
      response.body.should have_selector('.lbl label') do |lbl|
        fields.each_with_index do |fld, idx|
          lbl[idx]['for'].should == 'content_block_' + fld.to_s
        end
        fields.each do |fld|
          response.body.should have_selector '#content_block_' + fld.to_s
        end
      end
    end
  end

  describe '#admin/cacheflush' do
    it 'responds with error if not authorized' do
      get '/admin/cacheflush'
      last_response.status.should == 401
    end
    it 'calls cache flush' do
      login_as_admin
      SafeCache.expects(:flush)
      get '/admin/cacheflush'
    end
    it 'redirects to root' do
      login_as_admin
      get '/admin/cacheflush'
      last_response.status.should == 302
    end
  end
  describe 'helpers' do
  end
  
end

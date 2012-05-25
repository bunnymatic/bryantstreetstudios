require File.join(File.dirname(__FILE__),'spec_helper')
require File.join(File.dirname(__FILE__),'mockmau')
require File.join(File.dirname(__FILE__), '..','lib','string_generators')
require 'mime/types'

def login_as_admin
  authorize 'whatever', 'whatever'
end

describe BryantStreetStudios do
  include Rack::Test::Methods

  def app
    @app ||= BryantStreetStudios
  end

  # mock connection to mau setup with fakeweb in mockmau

  context 'Protected endpoints:' do
    [ :env, :events ].each do |endpoint|
      describe 'unauthorized GET' do
        it "#{endpoint} responds error" do
          get "/admin/"+endpoint.to_s
          last_response.status.should == 401
        end
      end
      describe 'authorized GET' do
        before do
          # authorize and get
          login_as_admin
          get "/admin/"+endpoint.to_s
        end
        it "#{endpoint} responds ok" do
          last_response.should be_ok
        end
        it "#{endpoint} uses the admin layout" do
          response_body.should have_selector('nav.admin') do |admin_section|
            admin_section.should have_selector('li') do |tag|
              tag.should have_selector('a', :count => 3) do |lnks|
                lnks[0]['href'].should == '/'
                lnks[0].should contain 'main site'
                lnks[1]['href'].should == '/admin/env'
                lnks[1].should contain 'env'
                lnks[2]['href'].should == '/admin/events'
                lnks[2].should contain 'events'
              end
            end
          end
        end
      end
    end
    [ ['/admin/events/update_attr', :id => '23_url', :value => 'url'],
      ['/admin/events', :event => {:starttime => 'yo'}]
    ].each do |endpoint|
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
    end
    it 'should return success' do
      get '/events'
      response.should be_ok
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

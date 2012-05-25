require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/mockmau'
require 'mime/types'


LETTERS_PLUS_SPACE =  (75).times.map{|num| (48+num).chr}.reject{|c| (c =~ /[[:punct:]]/)}
def gen_random_string(len=8)
  numchars = LETTERS_PLUS_SPACE.length
  (0..len).map{ LETTERS_PLUS_SPACE[rand(numchars)] }.join
end

describe BryantStreetStudios do
  include Rack::Test::Methods

  def app
    @app ||= BryantStreetStudios
  end

  # mock connection to mau setup with fakeweb in mockmau

  describe 'authorized urls' do
    describe 'GET' do
      [ :env ].each do |endpoint|
        it "#{endpoint} responds error with no auth" do
          get *endpoint
          last_response.status.should == 401
        end
        it "#{endpoint} responds ok with proper auth" do
          authorize 'whatever','whatever'
          get *endpoint
          last_response.should be_ok
        end
      end
    end
    describe 'POST' do
      [ ['/event/update_attr', :id => '23_url', :value => 'url'],
        ['/event', :event => {:starttime => 'yo'}]
      ].each do |endpoint|
        it "#{endpoint} responds error with no auth" do
          post *endpoint
          last_response.status.should == 401
        end
        it "#{endpoint} responds ok with proper auth" do
          authorize 'whatever','whatever'
          post *endpoint
          last_response.should be_ok
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

  describe '#cacheflush' do
    it 'calls cache flush' do
      SafeCache.expects(:flush)
      get '/cacheflush'
    end
    it 'redirects to root' do
      get '/cacheflush'
      last_response.status.should == 302
    end
  end
  describe 'helpers' do
  end
  
end

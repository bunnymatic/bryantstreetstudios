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
    it 'should list the artists in the sidebar' do
      get '/artists'
      response_body.should have_selector('li.thumb a .img', :count => 8)
      response_body.should have_selector('li.thumb a .name', :count => 8)
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

  describe '#press' do
    before do
      # putting the get here doesn't seem to work
    end
    it 'should return success' do
      get '/press'
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
      dc = mock('Dalli::ClientMock')
      dc.expects(:flush)
      Dalli::Client.expects(:new).returns(dc)
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

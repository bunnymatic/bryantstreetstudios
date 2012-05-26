require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../mockmau'
require 'mime/types'

describe ContentResource do
  it 'does not allow creation with the same page + section' do
    ContentResource.all.map(&:destroy)
    cr = ContentResource.create(:page => 'page1', :section => 'section', :body => 'Rock on')
    _id = cr.id
    cr = ContentResource.create(:page => 'page1', :section => 'section', :body => 'Rock on')
    cr.id.should be_nil
    cr.errors.should_not be_empty
    ContentResource.get(_id).body.should == 'Rock on'
  end
  it 'does not allow creation with the same page + blank sections' do
    ContentResource.all.map(&:destroy)
    cr = ContentResource.create(:page => 'page1', :body => 'Rock on')
    _id = cr.id
    cr = ContentResource.create(:page => 'page1', :body => 'Rock off')
    cr.id.should be_nil
    cr.errors.should_not be_empty
    ContentResource.get(_id).body.should == 'Rock on'
  end
end

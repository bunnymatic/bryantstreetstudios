require 'spec_helper'

describe ContentResource do
  it 'does not allow creation with the same page + section' do
    ContentResource.all.map(&:destroy)
    cr = ContentResource.create(:page => 'page1', :section => 'section', :body => 'Rock on')
    _id = cr.id
    cr = ContentResource.create(:page => 'page1', :section => 'section', :body => 'Rock on')
    expect(cr.id).to be_nil
    expect(cr.errors).not_to be_empty
    expect(ContentResource.get(_id).body).to eq 'Rock on'
  end
  it 'does not allow creation with the same page + blank sections' do
    ContentResource.all.map(&:destroy)
    cr = ContentResource.create(:page => 'page1', :body => 'Rock on')
    _id = cr.id
    cr = ContentResource.create(:page => 'page1', :body => 'Rock off')
    expect(cr.id).to  be_nil
    expect(cr.errors).not_to be_empty
    expect(ContentResource.get(_id).body).to eq 'Rock on'
  end
end

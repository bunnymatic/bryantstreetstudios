require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../mockmau'
require 'mime/types'

describe BreadCrumbs do
  context 'new' do
    it 'works' do
      lambda { BreadCrumbs.new }.should_not raise_error
    end
  end
  
  context 'render' do
    it 'returns html breadcrumbs given the [home]' do
      b = BreadCrumbs.new(['home']).render
      b.should have_selector '.breadcrumbs .crumb .name'
      b.should contain /home/
    end
    it 'returns html breadcrumbs given the [home,artists]' do
      b = BreadCrumbs.new(['home', 'artists']).render
      b.should have_selector '.breadcrumbs .crumb a .name'
      b.should have_selector '.breadcrumbs .crumb.last .name', :count => 1
      b.should contain /home/
      b.should contain /artists/
      b.should have_selector 'a[href="/"]'
    end
    it 'returns html breadcrumbs given the [home,artists, artist name]' do
      b = BreadCrumbs.new(['home', 'artists', 'paul morin']).render
      b.should have_selector '.breadcrumbs .crumb a .name', :count => 2
      b.should have_selector '.breadcrumbs .crumb.last .name'
      b.should contain /home/
      b.should contain /artists/
      b.should contain /paul morin/
      b.should have_selector 'a[href="/"]'
      b.should have_selector 'a[href="/artists"]'
    end
  end
end

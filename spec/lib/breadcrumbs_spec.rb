require 'spec_helper'

describe BreadCrumbs do
  context 'new' do
    it 'works' do
      expect{ BreadCrumbs.new }.not_to raise_error
    end
  end

  context 'render' do
    it 'returns html breadcrumbs given the [home]' do
      b = BreadCrumbs.new(['home']).render
      nodeb = Capybara::Node::Simple.new(b)
      expect(nodeb).to have_content /home/
      expect(nodeb).to have_selector '.breadcrumbs .crumb .name'
    end
    it 'returns html breadcrumbs given the [home,artists]' do
      b = BreadCrumbs.new(['home', 'artists']).render
      nodeb = Capybara::Node::Simple.new(b)
      expect(nodeb).to have_selector '.breadcrumbs .crumb a .name'
      expect(nodeb).to have_selector '.breadcrumbs .crumb.last .name', :count => 1
      expect(nodeb).to have_content /home/
      expect(nodeb).to have_content /artists/
      expect(nodeb).to have_selector 'a[href="/"]'
    end
    it 'returns html breadcrumbs given the [home,artists, artist name]' do
      b = BreadCrumbs.new(['home', 'artists', 'paul morin']).render
      nodeb = Capybara::Node::Simple.new(b)
      expect(nodeb).to have_selector '.breadcrumbs .crumb a .name', :count => 2
      expect(nodeb).to have_selector '.breadcrumbs .crumb.last .name'
      expect(nodeb).to have_content /home/
      expect(nodeb).to have_content /artists/
      expect(nodeb).to have_content /paul morin/
      expect(nodeb).to have_selector 'a[href="/"]'
      expect(nodeb).to have_selector 'a[href="/artists"]'
    end
  end
end

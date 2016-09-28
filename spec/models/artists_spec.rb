require 'spec_helper'

describe Artist, :vcr do
  describe 'make_link' do
    [ ["http://a.b.com/", "http://a.b.com/", "a.b.com/"],
      ["a.b.com/", "http://a.b.com/", "a.b.com/"],
      ["https://a.b.com/", "https://a.b.com/", "a.b.com/"] ].each do |vals|
      it "properly returns a link given an input url #{vals[0]} url" do
        url = Artist.make_link(vals[0])
        url = Capybara::Node::Simple.new(url)
        expect(url).to have_selector('a') do |tag|
          t = tag[0]
          expect(t.attributes['href'].value).to eq vals[1]
          expect(t.text).to eq vals[2]
        end
      end
    end
    it "uses the input text as specified" do
      url = Artist.make_link('http://mylink.com') do
        'check out my link'
      end
      url = Capybara::Node::Simple.new(url)
      expect(url).to have_selector('a') do |tag|
        t = tag[0]
        expect(t.attributes['href'].value).to eq 'http://mylink.com'
        expect(t.text).to eq 'check out my link'
      end
    end
    it "puts the options in the link as attributes" do
      url = Artist.make_link('http://mylink.com', {:class => 'theclass', :myattr => 'myval'}) do
        'eat it'
      end
      url = Capybara::Node::Simple.new(url)
      expect(url).to have_selector('a') do |tag|
        t = tag[0]
        expect(t.attributes['href'].value).to eq 'http://mylink.com'
        expect(t.attributes['class'].value).to eq 'theclass'
        expect(t.attributes['myattr'].value).to eq 'myval'
        expect(t.text).to eq == 'eat it'
      end
    end
  end
end

describe Artists, :vcr do
  context 'new' do
    before do
      @artists = Artists.new
    end

    it 'returns all artists in 1890 bryant' do
      expect(@artists.length).to eq 9
    end
    it 'returns iterable list of all artists' do
      expect(@artists).to respond_to :each
      expect(@artists).to respond_to :map
    end
    it 'returns artists with keyed by their id' do
      expect(@artists.all?{|artistid, artist| artist.id == artistid}).to eql(true), 'artist ids are not matched to their entries'
    end
    it 'contains hash keyed by Artist-s in the list of all artists' do
      expect(@artists.all?{ |artistid, artist| artist.class == Artist}).to eql(true), 'not all entries in the list are of the Artist class'
    end

  end

  context 'find' do
    let(:artist) { Artists.find(7) }

    it 'returns an Artist' do
      expect(artist).to be_a_kind_of Artist
    end
    it 'returns the correct artist' do
      expect(artist.id).to eq 7
    end
    it 'returns the artists\' art_pieces' do
      expect(artist.art_pieces.count).to eq 4
    end
    it 'returns all thumbnail sizes for an art_piece' do
      ap = artist.art_pieces.first
      ['thumb','small','medium','large'].each do |sz|
        expect(ap.images).to have_key sz
      end
    end
    it 'returns the correct media for the art piece' do
      ap = artist.art_pieces.first
      expect(ap.medium).to eq 'Painting - Oil'
    end
  end
end

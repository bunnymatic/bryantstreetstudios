require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../mockmau'
require 'mime/types'

describe Artist do
  describe 'make_link' do
    [ ["http://a.b.com/", "http://a.b.com/", "a.b.com/"],
      ["a.b.com/", "http://a.b.com/", "a.b.com/"],
      ["https://a.b.com/", "https://a.b.com/", "a.b.com/"] ].each do |vals|
      it "properly returns a link given an input url #{vals[0]} url" do
        url = Artist.make_link(vals[0])
        url.should have_selector('a') do |tag|
          t = tag[0]
          t.attributes['href'].value.should == vals[1]
          t.text.should == vals[2]
        end
      end
    end
    it "uses the input text as specified" do
      url = Artist.make_link('http://mylink.com') do
        'check out my link'
      end
      url.should have_selector('a') do |tag|
        t = tag[0]
        t.attributes['href'].value.should == 'http://mylink.com'
        t.text.should == 'check out my link'
      end
    end
    it "puts the options in the link as attributes" do
      url = Artist.make_link('http://mylink.com', {:class => 'theclass', :myattr => 'myval'}) do
        'eat it'
      end
      url.should have_selector('a') do |tag|
        t = tag[0]
        t.attributes['href'].value.should == 'http://mylink.com'
        t.attributes['class'].value.should == 'theclass'
        t.attributes['myattr'].value.should == 'myval'
        t.text.should == 'eat it'
      end
    end
  end
end

describe Artists do
  context 'new' do
    it 'returns all artists' do
      a = Artists.new
      a.length.should == 8
    end
    it 'returns iterable list of all artists' do
      a = Artists.new
      ct = 0
      a.each{|artistid, artist| ct = ct + 1}
      ct.should == 8
    end
    it 'returns artists with keyed by their id' do
      a = Artists.new
      ct = 0
      a.all?{|artistid, artist| artist.id == artistid}.should be_true, 'artist ids are not matched to their entries'
    end
    it 'contains hash keyed by Artist-s in the list of all artists' do
      a = Artists.new
      a.all?{ |artistid, artist| artist.class == Artist}.should be_true, 'not all entries in the list are of the Artist class'
    end
  end
  
  context 'find' do
    it 'returns an Artist' do
      a = Artists.find(11)
      a.should be_a_kind_of Artist
    end
    it 'returns the correct artist' do
      a = Artists.find(11)
      a.id.should == 11
    end
    it 'returns the artists\' art_pieces' do
      a = Artists.find(11).art_pieces.count.should == 10
    end
    it 'returns all thumbnail sizes for an art_piece' do
      ap = Artists.find(11).art_pieces.first
      ['thumb','small','medium','large'].each do |sz|
        ap.should have_key sz
      end
    end
    it 'returns the correct media for the art piece' do
      ap = Artists.find(11).art_pieces.first
      ap.should have_key 'media'
      ap['media'].should == 'Painting - Acrylic'
    end

  end
end

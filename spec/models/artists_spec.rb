require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../mockmau'
require 'mime/types'

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

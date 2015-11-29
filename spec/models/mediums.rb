require 'spec_helper'

describe Mediums do
  context 'new' do
    it 'returns all mediums' do
      m = Mediums.new
      m.length.should == 8
    end
    it 'returns iterable list of all mediums' do
      m = Mediums.new
      ct = 0
      m.each{|mediumid, medium| ct = ct + 1}
      ct.should == 8
    end
    it 'returns mediums with keyed by their id' do
      m = Mediums.new
      ct = 0
      m.all?{|mediumid, medium| medium.id == mediumid}.should be_true, 'medium ids are not matched to their entries'
    end
    it 'contains hash keyed by Medium-s in the list of all mediums' do
      m = Mediums.new
      m.all?{ |mediumid, medium| medium.class == Medium}.should be_true, 'not all entries in the list are of the Medium class'
    end
  end

  context 'find' do
    it 'returns an Medium' do
      m = Mediums.find(11)
      m.should be_a_kind_of Medium
    end
    it 'returns the correct medium' do
      m = Mediums.find(12)
      m.id.should == 12
      m.name.should == 'Painting - Acrylic'
    end
  end
end

require File.dirname(__FILE__) + '/../spec_helper'
require File.dirname(__FILE__) + '/../mockmau'
require 'mime/types'

describe Studio do
  context 'new' do
    it 'returns 1890 bryant' do
      s = Studio.new
      s.name.should == '1890 Bryant Street Studios'
    end
  end
end

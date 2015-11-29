require 'spec_helper'

describe Studio, :vcr do
  context 'new' do
    it 'returns 1890 bryant' do
      s = Studio.new
      expect(s.name).to include '1890 Bryant'
    end
  end
end

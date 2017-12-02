require File.join(File.dirname(__FILE__),'spec_helper')

Dir[File.join(File.dirname(__FILE__),'..',"{lib,models}/**/*.rb")].each do |file|
  require file
end
DataMapper.auto_migrate!

describe BryantStreetStudios, :vcr do

  def login_as_admin
    authorize 'whatever','whatever'
  end

  def app
    @app ||= BryantStreetStudios
  end

  def setup_fixtures
    ContentResource.all.map(&:destroy)
    ContentResource.create({:page => 'events', :section => 's', :body => "## Here's what we've got planned\n\n* this\n*that\n\n"})
  end

  before do
    SafeCache.flush
  end

  context 'Protected endpoints:' do
    [ :pictures, :content_block, :content_blocks, :env, :exclusions ].each do |endpoint|
      describe 'unauthorized GET' do
        it "/admin/#{endpoint} responds error" do
          get "/admin/"+endpoint.to_s
          expect(last_response.status).to eql 401
        end
      end
    end
    [ '/admin/picture'].each do |endpoint|
      describe 'unauthorized POST' do
        it "#{endpoint} responds error" do
          post *endpoint
          expect(last_response.status).to eql 401
        end
      end
    end
  end

  describe '#index' do
    before do
      # putting the get here doesn't seem to work
    end
    it 'returns success' do
      visit '/'
      expect(page).to have_content '1890'
    end
  end

  describe '#artists' do
    it 'should list the artists in the sidebar' do
      visit '/artists'
      expect(page).to have_css('.sidebar li.artist a .name')
    end
    it 'should list the artists with art pieces in the content' do
      visit '/artists'
      expect(page).to have_selector('.content li.thumb a .img')
      expect(page).to have_selector('.content li.thumb a .name')
    end
    it 'artists are listed alphabetically' do
      visit '/artists'
      expect(page).to have_selector('.content li.thumb .name') do |names|
        expect(names[0]).to contain 'Rhiannon'
        expect(names.last).to contain 'caitlin winner'
      end
      expect(page).to have_selector('.sidebar li.artist .name') do |names|
        expect(names[0]).to contain 'Rhiannon'
        expect(names.last).to contain 'caitlin winner'
      end
    end

  end

  describe '#artists/:id' do
    it 'shows the artist\'s name in the title' do
      visit '/artists/1'
      expect(page).to have_selector '.title' do |t|
        expect(t).to contain 'Martin Sally'
      end
    end
    # it 'draws the artist\'s links as links' do
    #   visit '/artists/7'
    #   expect(page).to have_selector '.contact div.website span a' do |t|
    #     t = t[0]
    #     expect(t.attributes['href'].value).to eql 'http://catherinemackey.com'
    #     expect(t.text).to eql 'catherinemackey.com'
    #   end
    # end

  end

  describe '#events' do
    before do
      # putting the get here doesn't seem to work
      setup_fixtures
    end
    it 'should render the content block for events' do
      visit '/events'
      expect(page).to have_selector 'h2' do |chunk|
        expect(chunk).to contain 'Here\'s what we\'ve got planned'
      end
    end
  end

  describe '#contact' do
    before do
      # putting the get here doesn't seem to work
    end
    it 'returns success' do
      visit '/contact'
      expect(page).to have_content "General Inquiries"
      expect(page).to have_content "94110"
    end
  end
end

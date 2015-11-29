require 'spec_helper'

Dir[File.join(File.dirname(__FILE__),'..',"{lib,models}/**/*.rb")].each do |file|
  require file
end
DataMapper.auto_migrate!

describe BryantStreetStudios, vcr: { record: :new_episodes } do

  def basic_auth(name, password)
    if page.driver.respond_to?(:basic_auth)
      page.driver.basic_auth(name, password)
    elsif page.driver.respond_to?(:basic_authorize)
      page.driver.basic_authorize(name, password)
    elsif page.driver.respond_to?(:browser) && page.driver.browser.respond_to?(:basic_authorize)
      page.driver.browser.basic_authorize(name, password)
    else
      raise "I don't know how to log in!"
    end
  end

  def login_as_admin
    authorize 'whatever','whatever'
    basic_auth 'whatever','whatever'
  end

  def app
    @app ||= BryantStreetStudios
  end

  def setup_fixtures
    ContentResource.all.map(&:destroy)
    ContentResource.create({:page => 'events', :section => 's', :body => "## Here's what we've got planned\n\n* this\n*that\n\n"})

    ArtistExclusion.all.map(&:destroy)
    ArtistExclusion.create({:name => 'this dude'})
    ArtistExclusion.create({:name => 'that dude'})
    ArtistExclusion.create({:name => 'Mr Rogers'})
    ArtistExclusion.create({:name => 'That dud'})
    ArtistExclusion.create({:name => 'That dude', :case_insensitive => false})
  end

  context 'Admin pages: ' do
    [ :pictures, :content_block, :content_blocks, :env, :exclusions ].each do |endpoint|
      it "/admin/#{endpoint} responds ok when you're logged in" do
        login_as_admin
        get "/admin/"+endpoint.to_s
        expect(last_response).to be_ok
      end
      it "/admin/#{endpoint} uses the admin layout" do
        login_as_admin
        visit "/admin/"+endpoint.to_s
        within 'nav.admin' do
          expect(page).to have_css('li a', count: 5)
          lnks = all('li a')

          expect(lnks[0]['href']).to eq '/admin'
          expect(lnks[0]).to have_content 'dashboard'
          expect(lnks[1]['href']).to eq '/admin/pictures'
          expect(lnks[1]).to have_content 'pictures'
          expect(lnks[2]['href']).to eq '/admin/content_blocks'
          expect(lnks[2]).to have_content 'content blocks'
          expect(lnks[3]['href']).to eq '/admin/exclusions'
          expect(lnks[3]).to have_content 'exclusions'
          expect(lnks[4]['href']).to eq '/admin/env'
          expect(lnks[4]).to have_content 'env'
        end
        expect(page).to have_selector('a .logo')
      end
    end
  end

  ########## Admin endpoints

  ## Content Blocks
  describe '#admin/content_blocks' do
    before do
      login_as_admin
    end
    it 'shows a list of content blocks with edit and delete links' do
      setup_fixtures
      visit '/admin/content_blocks'
      _ids = ContentResource.all.map(&:id)
      within 'tbody tr' do
        expect(page).to have_selector('a')
        links = all('a')
        expect(links[0]).to have_selector('img[title=edit]')
        expect(links[1]).to have_selector('img[title=trash]')
        expect(links[0]['href']).to eq "/admin/content_block/#{_ids.first}"
        expect(links[1]['href']).to eq "/admin/content_block/#{_ids.first}/delete"
      end
    end
  end


  describe '#admin/content_block' do
    before do
      login_as_admin
      setup_fixtures
    end
    context "GET" do
      it 'shows the expected fields: page, section, body' do
        visit '/admin/content_block'
        fields = [:page, :section, :body]
        expect(page).to have_selector('.lbl label', count: 3)
        fields.each do |fld|
          expect(page).to have_selector '#content_block_' + fld.to_s
          expect(page).to have_selector "label[for=\"#{'content_block_' + fld.to_s}\"]"
        end
      end
      it 'shows the expected fields: page, section, body' do
        cr = ContentResource.all.last
        visit "/admin/content_block/#{cr.id}"
        fields = [:page, :section, :body]
        expect(page).to have_selector('.lbl label', count: 3)
        fields.each do |fld|
          expect(page).to have_selector '#content_block_' + fld.to_s
          expect(page).to have_selector "label[for=\"#{'content_block_' + fld.to_s}\"]"
        end

        inp = find("#content_block_id", visible: false)
        expect(inp['type']).to eql 'hidden'
        expect(inp['value']).to eql cr.id.to_s

        expect(page).to have_selector "#content_block_page[value=#{cr.page}]"
        expect(page).to have_selector "#content_block_section[value=#{cr.section}]"
        textarea = find('#content_block_body')
        expect(textarea.value.to_s.gsub(/\s+/, ' ').strip).to include cr.body.gsub(/\s+/, ' ').strip
      end
    end
    context 'POST' do
      it 'creates a new resource block with content but without an id' do
        body = [gen_random_string(10), gen_random_string(20)].join(" ")
        page = gen_random_string
        old_count = ContentResource.all.count
        post '/admin/content_block', :content_block => {:page => page, :body => body }
        expect(ContentResource.all.count).to eq (old_count + 1)
        expect(ContentResource.all.last.body).to eq body
        expect(ContentResource.all.last.page).to eq page
      end
      it 'edit a resource block with new content' do
        cr = ContentResource.all.last
        body = [gen_random_string(10), gen_random_string(20)].join(" ")
        old_count = ContentResource.all.count
        post '/admin/content_block', :content_block => {:id => cr.id, :body => body }
        expect(ContentResource.all.count).to eq old_count
        expect(ContentResource.get(cr.id.to_i).body).to eq body
        expect(ContentResource.get(cr.id.to_i).page).to eq cr.page
      end
      it 'edit redirects to content_blocks index' do
        cr = ContentResource.all.last
        body = [gen_random_string(10), gen_random_string(20)].join(" ")
        post '/admin/content_block', :content_block => {:id => cr.id, :body => body }
        expect(last_response.status).to eq 302
      end
    end
  end

  describe '#admin/content_block/:id/delete' do
    before do
      login_as_admin
      setup_fixtures
    end
    it 'deletes the resource' do
      cr = ContentResource.all.last
      expect(cr).not_to be_nil
      get "/admin/content_block/#{cr.id}/delete"
      expect(ContentResource.get(cr.id.to_i)).to be_nil
    end
    it 'redirects to content blocks index' do
      cr = ContentResource.all.last
      expect(cr).not_to be_nil
      get "/admin/content_block/#{cr.id}/delete"
      expect(last_response.status).to eq 302
    end
  end


  ## pictures
  ### index
  describe '#admin/pictures' do
    before do
      login_as_admin
    end
    it 'shows a list of content blocks with edit and delete links' do
      mock_pics = [
        double(:picture => double(:url => 'url1'), :id => 10),
        double(:picture => double(:url => 'url2'), :id => 12)
      ]
      allow(PictureResource).to receive(:all).and_return( mock_pics )

      visit '/admin/pictures'
      pics = PictureResource.all.reverse
      expect(page).to have_selector('ul li.picture')
      trash_links = all('.picture .del a')
      trash_links.each_with_index do |t,idx|
        expect(t).to have_selector 'img[title=trash]'
        expect(t['href']).to eql "/admin/picture/#{pics[idx].id}/delete"
      end
      urls = all('.picture .url input')
      urls.each_with_index do |url, idx|
        expect(url.value).to eql pics[idx].picture.url
      end
    end
  end

  ## artist exclusions
  ### index
  describe '#admin/exclusions' do
    before do
      login_as_admin
    end
    it 'shows all current exclusions' do
      visit '/admin/exclusions'
      expect(page).to have_css 'ul.exclusions li.row', count: ArtistExclusion.count
      expect(page).to have_css 'ul.exclusions .row .name', count: ArtistExclusion.count
      expect(page).to have_css 'ul.exclusions .row .case_insensitive', count: ArtistExclusion.count
      expect(page).to have_css 'ul.exclusions .row a.delete_link', count: ArtistExclusion.count
      expect(page).to have_css 'ul.exclusions .row[data-aeid]', count: ArtistExclusion.count
    end
  end

  ### new
  describe 'POST#admin/exclusion' do
    before do
      login_as_admin
      setup_fixtures
    end
    it 'creates a new exclusion given good data' do
      expect {
        post '/admin/exclusion', "exclusion[name]" => 'mister mister', "exclusion[case_insensitive]" => 'false'
      }.to change(ArtistExclusion, :count).by(1)
    end
    it 'redirects to the index page' do
      post '/admin/exclusion', "exclusion[name]" => 'mister mister', "exclusion[case_insensitive]" => 'false'
      expect(last_response.status).to eq 302
    end
    it 'creates a sets the values correctly' do
      post '/admin/exclusion', "exclusion[name]" => 'mister mister', "exclusion[case_insensitive]" => 'false'
      aex = ArtistExclusion.all(:name => 'mister mister')
      expect(aex).to be_present
      expect(aex.count).to eql 1
      expect(aex[0].case_insensitive).to eql false
      expect(aex[0].name).to eql 'mister mister'
    end
  end
  ## others

  describe '#admin/cacheflush' do
    it 'responds with error if not authorized' do
      get '/admin/cacheflush'
      expect(last_response.status).to eq 401
    end
    it 'calls cache flush' do
      login_as_admin
      expect(SafeCache).to receive(:flush)
      get '/admin/cacheflush'
    end
    it 'redirects to root' do
      login_as_admin
      get '/admin/cacheflush'
      expect(last_response.status).to eq 302
    end
  end

end

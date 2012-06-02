require File.join(File.dirname(__FILE__),'spec_helper')
require File.join(File.dirname(__FILE__),'mockmau')

Dir[File.join(File.dirname(__FILE__),'..',"{lib,models}/**/*.rb")].each do |file|
  require file
end
DataMapper.finalize
DataMapper.auto_migrate!
require 'mime/types'

describe BryantStreetStudios do
  include Rack::Test::Methods

  def login_as_admin
    authorize 'whatever','whatever'
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

  # mock connection to mau setup with fakeweb in mockmau
  # unauthorized connections are tested in the main app spec
  context 'Admin pages: ' do
    [ :pictures, :content_block, :content_blocks, :env, :exclusions ].each do |endpoint|
      it "/admin/#{endpoint} responds ok when you're logged in" do
        login_as_admin
        get "/admin/"+endpoint.to_s
        last_response.should be_ok
      end
      it "/admin/#{endpoint} uses the admin layout" do
        login_as_admin
        get "/admin/"+endpoint.to_s
        response_body.should have_selector('nav.admin') do |admin_section|
          admin_section.should have_selector('li') do |tag|
            tag.should have_selector('a', :count => 5) do |lnks|
              lnks[0]['href'].should == '/'
              lnks[0].should contain 'main site'
              lnks[1]['href'].should == '/admin/pictures'
              lnks[1].should contain 'pictures'
              lnks[2]['href'].should == '/admin/content_blocks'
              lnks[2].should contain 'content blocks'
              lnks[3]['href'].should == '/admin/exclusions'
              lnks[3].should contain 'exclusions'
              lnks[4]['href'].should == '/admin/env'
              lnks[4].should contain 'env'
            end
          end
        end
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
      get '/admin/content_blocks'
      _ids = ContentResource.all.map(&:id)
      response_body.should have_selector('tbody tr') do |blk|
        blk.should have_selector('a') do |lnk|
          lnk.should have_selector('img[title=edit]')
          lnk.should have_selector('img[title=trash]')
          lnk[0]['href'].should == "/admin/content_block/#{_ids.first}"
          lnk[1]['href'].should == "/admin/content_block/#{_ids.first}/delete"
        end
      end
    end
  end


  describe '#admin/content_block' do
    before do
      login_as_admin
    end
    context "GET" do
      it 'shows the expected fields: page, section, body' do
        get '/admin/content_block'
        fields = [:page, :section, :body]
        response.body.should have_selector('.lbl label') do |lbl|
          fields.each_with_index do |fld, idx|
            lbl[idx]['for'].should == 'content_block_' + fld.to_s
          end
          fields.each do |fld|
            response.body.should have_selector '#content_block_' + fld.to_s
          end
        end
      end
      it 'shows the expected fields: page, section, body' do
        cr = ContentResource.all.last
        get "/admin/content_block/#{cr.id}"
        fields = [:page, :section, :body]
        response.body.should have_selector('.lbl label') do |lbl|
          fields.each_with_index do |fld, idx|
            lbl[idx]['for'].should == 'content_block_' + fld.to_s
          end
        end
        response.body.should have_selector "#content_block_id" do |inp|
          inp[0]['value'].should == cr.id.to_s
          inp[0]['type'].should == 'hidden'
        end
        response.body.should have_selector "#content_block_page[value=#{cr.page}]"
        response.body.should have_selector "#content_block_section[value=#{cr.section}]"
        response.body.should have_selector "textarea#content_block_body" do |tarea|
          tarea.to_s.gsub(/\s+/, ' ').strip.should contain cr.body.gsub(/\s+/, ' ').strip
        end
      end
    end
    context 'POST' do
      it 'creates a new resource block with content but without an id' do
        body = [gen_random_string(10), gen_random_string(20)].join(" ")
        page = gen_random_string
        old_count = ContentResource.all.count
        post '/admin/content_block', :content_block => {:page => page, :body => body }
        ContentResource.all.count.should == (old_count + 1)
        ContentResource.all.last.body.should == body
        ContentResource.all.last.page.should == page
      end
      it 'edit a new resource block with content but without an id' do
        cr = ContentResource.all.last
        body = [gen_random_string(10), gen_random_string(20)].join(" ")
        old_count = ContentResource.all.count
        post '/admin/content_block', :content_block => {:id => cr.id, :body => body }
        ContentResource.all.count.should == (old_count)
        ContentResource.all.last.body.should == body
        ContentResource.all.last.page.should == cr.page
      end
      it 'edit redirects to content_blocks index' do
        cr = ContentResource.all.last
        body = [gen_random_string(10), gen_random_string(20)].join(" ")
        post '/admin/content_block', :content_block => {:id => cr.id, :body => body }
        last_response.status.should == 302
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
      cr.should be
      get "/admin/content_block/#{cr.id}/delete"
      ContentResource.get(cr.id).should be_nil
    end
    it 'redirects to content blocks index' do
      cr = ContentResource.all.last
      cr.should be
      get "/admin/content_block/#{cr.id}/delete"
      last_response.status.should == 302
    end
  end

  
  ## pictures
  ### index
  describe '#admin/pictures' do
    before do
      login_as_admin
    end
    it 'returns success' do
      PictureResource.stubs(:all => [ stub(:picture => stub(:url => 'url1'), :id => 10),
                                      stub(:picture => stub(:url => 'url2'), :id => 12) ])
      get '/admin/pictures'
      last_response.status.should == 200
    end
    it 'shows a list of content blocks with edit and delete links' do
      PictureResource.stubs(:all => [ stub(:picture => stub(:url => 'url1'), :id => 10),
                                      stub(:picture => stub(:url => 'url2'), :id => 12) ])
      get '/admin/pictures'
      pics = PictureResource.all.reverse
      response_body.should have_selector('ul li.picture') do |blk|
        blk.each_with_index do |b,idx|
          b.should have_selector('.del a') do |lnk|
            lnk.should have_selector('img[title=trash]')
            lnk[0]['href'].should == "/admin/picture/#{pics[idx].id}/delete"
          end
          b.should have_selector('.url input') do |inp|
            inp[0]['value'].should eql pics[idx].picture.url
          end
        end
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
      get '/admin/exclusions'
      response_body.should have_selector('ul.exclusions li', :count => ArtistExclusion.count) do |tags|
        tags.each do |tag|
          tag.should have_selector '.name'
          tag.should have_selector '.case_insensitive'
          tag.should have_selector '.delete_link'
          tag.attributes['data-aeid'].value.should be_true
        end
      end
    end
  end

  ### new
  describe 'POST#admin/exclusion' do
    before do
      login_as_admin
      setup_fixtures      
    end
    it 'creates a new exclusion given good data' do
      lambda {
        post '/admin/exclusion', "exclusion[name]" => 'mister mister', "exclusion[case_insensitive]" => 'false'
      }.should change(ArtistExclusion, :count).by(1)
    end
    it 'redirects to the index page' do
      post '/admin/exclusion', "exclusion[name]" => 'mister mister', "exclusion[case_insensitive]" => 'false'
      last_response.status.should == 302
    end
    it 'creates a sets the values correctly' do
      post '/admin/exclusion', "exclusion[name]" => 'mister mister', "exclusion[case_insensitive]" => 'false'
      aex = ArtistExclusion.all(:name => 'mister mister')
      aex.should be_true
      aex.count.should == 1
      aex[0].case_insensitive.should be_false
      aex[0].name.should eql 'mister mister'
    end
  end
  ## others

  describe '#admin/cacheflush' do
    it 'responds with error if not authorized' do
      get '/admin/cacheflush'
      last_response.status.should == 401
    end
    it 'calls cache flush' do
      login_as_admin
      SafeCache.expects(:flush)
      get '/admin/cacheflush'
    end
    it 'redirects to root' do
      login_as_admin
      get '/admin/cacheflush'
      last_response.status.should == 302
    end
  end
  describe 'helpers' do
  end
  
end

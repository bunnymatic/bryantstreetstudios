require 'sinatra'
require 'data_mapper'

class ContentResource
  include DataMapper::Resource
  property :id, Serial
  property :page, String, :length => 255
  property :section, String, :length => 255, :default => ''
  property :body, String, :length => 4048

  validates_presence_of :page
  #This doesn't seem to work properly if the :section is not blank
  #validates_uniqueness_of :section, :scope => :page, :message => 'That page already has that section'
  validates_with_method :unique_page_and_section
  
  def unique_page_and_section
    r = ContentResource.all(:page => self.page, :section => self.section)
    # don't fail if we're editing the same item
    if self.id && !r.empty?
      r = r.empty? ? nil : r.reject{|r| r.id == self.id}
    end
    r.empty? ? true : [false, 'That page already has that section']
  end
end

DataMapper.finalize

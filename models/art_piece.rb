require 'dalli'
require_relative './mau_model'

class ArtPiece < MauModel

  attr_reader :model

  def initialize(model_data)
    @model = model_data
  end

  def id
    @model['id']
  end

  def medium
    medium = Mediums.find(@model['medium_id']) if @model['medium_id']
    medium.name if medium
  end

  def dimensions
    @model['dimensions']
  end

  def title
    @model['title']
  end

  def year
    @model['year']
  end

  def images
    return @images if @images
    images = ['thumb', 'small', 'medium', 'large'].map { |k|
      [k, image_file(k)] if image_file(k)
    }.reject{|k,v| v.nil?}
    Hash[images]
  end

  def thumbnail
    images['thumb']
  end

  def photo
    @model['photo'] if @model['photo'].present?
  end

  def filename
    @model['filename'] if @model['filename'].present?
  end

  private

  def image_file(sz = nil)
    f = photo || filename
    return f if f.nil? || /^http/ =~ f
    case sz
    when 'thumb'
      image_path(f, 't_')
    when 'small'
      image_path(f, 's_')
    when 'medium'
      image_path(f, 'm_')
    when 'large'
      image_path(f, 'l_')
    else
      f
    end
  end

  def image_path(filename, prefix)
    filename = clean_filename(filename)
    base_file = File.basename(filename)
    dest_file = prefix + base_file
    file_match = Regexp.new(base_file + "$")

    File.join( conf.mau_web_url, filename.gsub(file_match, dest_file) )
  end

  def clean_filename(file)
    file.gsub(%r|^.*/artistdata/|, 'artistdata/')
  end

  def conf
    @conf ||= BryantStreetStudios.settings
  end

end

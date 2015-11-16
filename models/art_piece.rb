require 'dalli'
require 'rest_client'
require 'ostruct'
require 'uri'

class ArtPiece

  attr_reader :model

  def initialize(model_data)
    @model = model_data
  end

  def id
    @model['id']
  end

  def medium
    Mediums.find(@model['medium_id']).name if @model['medium_id']
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
      [k, image_file(k)]
    }
    Hash[images]
  end

  def thumbnail
    images['thumb']
  end

  private

  def image_file(sz = nil)
    f = @model['filename']
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
    return filename if /^http/ =~ filename

    base_file = File.basename(filename)
    dest_file = prefix + base_file
    file_match = Regexp.new(base_file + "$")
    File.join( conf.mau_web_url, filename.gsub(file_match, dest_file).gsub(%r|public/artistdata/|, 'artistdata/') )
  end

  def conf
    @conf ||= BryantStreetStudios.settings
  end




end

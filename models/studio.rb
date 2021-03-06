require 'dalli'
require_relative './mau_model'

class Studio < MauModel

  def name
    model['name']
  end

  def slug
    model['slug']
  end

  def artists
    model['artists']
  end

  def to_param
    model['slug'] || model['id']
  end

  private
  def model
    @model ||=
      begin
        studio = SafeCache.get('studio')
        return studio if studio
        studio = get_json( "studios/#{config.mau_studio_id}.json" )
        if studio.has_key? 'studio'
          studio = studio['studio']
        end
        SafeCache.set('studio', studio)
        studio
      end
  end


end

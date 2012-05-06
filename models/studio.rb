require 'dalli'
require 'rest_client'

class Studio 
  ALLOWED_KEYS = ["id", "name", "image_height", "image_width", "city", "street", "state", "zip", "cross_street", "lat", "lng", "profile_image", "phone"] 

  @@studio = nil

  def initialize
    conf = BryantStreetStudios.config
    studio = BryantStreetStudios.cache.get('studio')
    if !studio
      url = "%s/studios" % conf.mau_api_url
      begin 
        resp = RestClient.get url
        studios = JSON.parse(resp.body)
      rescue Exception => ex
        puts "ERROR: Unable to connect to #{url}"
        puts "Exception: #{ex.to_s}"
      end

      studio = nil
      studios.map{|s| s['studio']}.each do |st|
        if st['name'] =~ /^1890/
          studio = st
          break
        end
      end unless studios.nil?
      BryantStreetStudios.cache.set('studio', studio) if studio
    end
    @@studio = studio
  end

  def method_missing(meth, *args, &block)
    if ALLOWED_KEYS.include? meth.to_s
      @@studio[meth.to_s]
    else 
      super
    end
  end
end

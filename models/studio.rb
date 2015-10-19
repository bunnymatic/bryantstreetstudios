require 'dalli'
require 'byebug'

class Studio
  ALLOWED_KEYS = %w|id name city street state zip cross_street lat lng profile_image phone slug artists|

  @@studio = nil

  def to_param
    studio["slug"] || studio["id"]
  end

  def method_missing(meth, *args, &block)
    if ALLOWED_KEYS.include? meth.to_s
      studio[meth.to_s]
    else
      super
    end
  end

  private
  def studio
    conf = BryantStreetStudios.settings
    _studio = SafeCache.get('studio')

    if !_studio
      studios = MAU::RestClient.get_json("%s/studios.json" % conf.mau_api_url).fetch "studios"
      # begin
      #   resp = MAU::RestClient.get_json url
      #   studios = Oj.load(resp.body).fetch "studios"
      # rescue Exception => ex
      #   puts "ERROR: Unable to connect to #{url}"
      #   puts "Exception: #{ex.to_s}"
      # end
      _studio = studios.select{|s| s['name'] =~ /^1890/}.first if studios.present?
      SafeCache.set('studio', _studio) if _studio
    end
    @@studio = _studio
  end

end

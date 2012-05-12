require 'dalli'
class SafeCache 

  def self.init()
    @@cache ||= Dalli::Client.new('localhost:11211', :expires_in => BryantStreetStudios.settings.cache_expiry)
  end

  def self.get(*args)
    begin 
      cache.get *args
    rescue Dalli::RingError
      #ignore
      nil
    end
  end
  
  def self.set(*args)
    begin 
      cache.set *args
    rescue Dalli::RingError
      #ignore
      nil
    end
  end

  private
  def self.cache
    init
  end
end


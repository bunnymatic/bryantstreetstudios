require 'dalli'
class SafeCache 

  def self.init
    @@cache ||= Dalli::Client.new('localhost:11211', :expires_in => BryantStreetStudios.settings.cache_expiry)
  end

  def self.get(*args)
    begin 
      args[0] = BryantStreetStudios.settings.cache_prefix + args[0]
      cache.get *args
    rescue Dalli::RingError
      #ignore
      nil
    end
  end
  
  def self.set(*args)
    begin 
      args[0] = BryantStreetStudios.settings.cache_prefix + args[0]
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


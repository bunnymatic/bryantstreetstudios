require 'dalli'
class SafeCache

  def self.init
    if ['MEMCACHIER_SERVERS', 'MEMCACHIER_USERNAME', 'MEMCACHIER_PASSWORD'].all?{|k| ENV.has_key? k}
      @@cache ||= Dalli::Client.new(ENV["MEMCACHIER_SERVERS"].split(","),
                                    {:username => ENV["MEMCACHIER_USERNAME"],
                                      :password => ENV["MEMCACHIER_PASSWORD"]})
    else
      @@cache ||= Dalli::Client.new('localhost:11211', {:expires_in => BryantStreetStudios.settings.cache_expiry})
    end
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

  def self.flush
    begin
      cache.flush
    rescue Dalli::RingError => ex
      puts "*** Failed to flush cache #{ex}"
    end
  end

  private
  def self.cache
    init
  end
end

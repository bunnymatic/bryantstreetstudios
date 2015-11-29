require 'logger'

class MauModel

  def self.logger
    @logger ||= Logger.new(STDOUT)
  end

  def get_json(path)
    self.class.get_json(path)
  end

  def self.get_json(path)
    logger.info "Fetching data from #{api_url(path)}"
    MAU::RestClient.get_json( api_url( path ) )
  end

  def self.base_url
    config.mau_api_url
  end

  def self.api_url(path)
    "#{base_url}/#{path}"
  end

  def config
    self.class.config
  end

  def self.config
    @config ||= BryantStreetStudios.settings
  end

  # def logger
  #   self.class.logger
  # end

  # def self.logger
  #   require 'byebug'
  #   debugger
  #   @logger ||= BryantStreetStudios.logger
  # end

end

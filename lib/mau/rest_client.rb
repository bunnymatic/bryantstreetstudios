require_relative '../mau.rb'
require 'rest_client'

module MAU
  class RestClient

    DEFAULT_HEADERS = {
      "Authorization" => BryantStreetStudios.mau_api_key
    }.freeze

    def self.get(url, headers: {})
      ctx = DEFAULT_HEADERS.merge(headers)
      ::RestClient.get url, ctx
    end

    def self.get_json(url, headers: {})
      begin
        json_headers = { "Content-Type" => "application/json" }.merge(headers)
        resp = self.get url, headers: json_headers
        Oj.load(resp.body)
      rescue  RestClient::Exception => ex
        puts "ERROR: Unable to connect to #{url}"
        puts "Exception: #{ex.to_s}"
      rescue  Oj::ParseError => ex
        puts "ERROR: Unable to parse the response from #{url} - invalid json"
        puts "Exception: #{ex.to_s}"
      end
    end

  end
end

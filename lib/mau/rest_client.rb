require_relative '../mau.rb'
require 'rest_client'

module MAU
  class RestClient

    DEFAULT_HEADERS = {
      "Authorization" => "Secret Word Goes Here"
    }.freeze

    def self.get(url, headers: {})
      ::RestClient.get url, DEFAULT_HEADERS.merge(headers)
    end

    def self.get_json(url, headers: {})
      begin
        json_headers = { "Content-Type" => "application/json" }.merge(headers)
        resp = self.get url, headers: json_headers
        Oj.load(resp.body)
      rescue Exception => ex
        puts "ERROR: Unable to connect to #{url}"
        puts "Exception: #{ex.to_s}"
      end
    end

  end
end

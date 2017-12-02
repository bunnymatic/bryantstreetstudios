require 'vcr'

VCR.configure do |config|
  config.hook_into :webmock
  config.cassette_library_dir = 'spec/fixtures/vcr-cassettes'
  config.configure_rspec_metadata!
  # Uncomment these and start a local MAU server to re-record
  # config.allow_http_connections_when_no_cassette = true
  # config.default_cassette_options = { record: :all }
end

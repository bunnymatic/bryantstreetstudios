require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "fixtures/vcr/"
  config.hook_into :fakeweb
end

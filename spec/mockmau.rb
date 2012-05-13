require 'fakeweb'
require 'open-uri'

FakeWeb.allow_net_connect = false

[:media, :artists, :studios].each do |k|
  datafile = File.join(File.dirname(__FILE__), "fakeweb_data/#{k}.json")
  body = File.read(File.open(datafile,'r'))
  FakeWeb.register_uri(:any, /.*\/api\/#{k}$/, :body => body)
end
[1..100].each do |artist_id|
  datafile = File.join(File.dirname(__FILE__), "fakeweb_data/artist#{artist_id}.json")
  if File.exists? datafile
    body = File.read(File.open(datafile,'r'))
    FakeWeb.register_uri(:any, /.*\/api\/artists\/#{artist_id}/, :body => "fakeweb_data/artist#{artist_id}.json")
  end
end

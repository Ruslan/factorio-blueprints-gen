require 'base64'
require 'json'
require 'zlib'

require './lib/blueprint_generator.rb'
require './lib/station_provider.rb'
require './lib/station_requester.rb'



gen = StationProvider.new
gen.stack_size = 100
gen.item_name = "[item=se-beryllium-ingot]"
gen.call
puts gen.blueprint


# blueprint_json = JSON.parse(File.read('templates/station_provider.json'))

# puts '0' + Base64.encode64(Zlib::Deflate.deflate(blueprint_json.to_json))

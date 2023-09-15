require 'base64'
require 'json'
require 'zlib'

require './lib/item.rb'
require './lib/items.rb'
require './lib/blueprint_generator.rb'
require './lib/station_provider.rb'
require './lib/station_requester.rb'
require './lib/station_train.rb'

require 'pry'

item = Items.new("realm1.json").find("se-beryllium-ingot")

gen = StationProvider.new(item)
gen.call
puts "\n\n===PROVIDER===\n\n"
puts gen.blueprint

gen = StationRequester.new(item)
gen.call
puts "\n\n===REQUESTER===\n\n"
puts gen.blueprint

gen = StationTrain.new(item)
gen.call
puts "\n\n===Train===\n\n"
puts gen.blueprint

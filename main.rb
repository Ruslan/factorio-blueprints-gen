require 'base64'
require 'json'
require 'zlib'

require './lib/item.rb'
require './lib/items.rb'
require './lib/blueprint_generator.rb'
require './lib/blueprint_book.rb'
require './lib/station_provider.rb'
require './lib/station_requester.rb'
require './lib/station_train.rb'

require 'pry'

resource = ARGV[0]
unless resource&.size&.positive?
  puts "usage: main.rb ITEMNAME"
  return
end

item = Items.new("realm1.yml").find(resource)

puts "~~~~[#{item.name}]~~~~"
puts

book = BlueprintBook.new

gen = StationProvider.new(item)
gen.call
book.add_blueprint_decoded(gen.blueprint_json)

gen = StationRequester.new(item)
gen.call
book.add_blueprint_decoded(gen.blueprint_json)

gen = StationTrain.new(item)
gen.call
book.add_blueprint_decoded(gen.blueprint_json)

puts book.blueprint

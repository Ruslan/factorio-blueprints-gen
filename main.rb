require 'base64'
require 'json'
require 'zlib'

require './lib/item.rb'
require './lib/realm.rb'
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

realm = Realm.new("realm1.yml")
item = Items.new(realm).find(resource)

puts "~~~~[#{item.name}]~~~~"
puts

# DEBUG
# gen = StationRequester.new(item, belts_type: realm.setting('belts_type'), inserter_type: realm.setting('inserter_type'), priority: -1)
# gen.call
# # puts JSON.pretty_generate(gen.blueprint_json)
# puts gen.blueprint
# exit
# END

book = BlueprintBook.new

gen = StationProvider.new(item, belts_type: realm.setting('belts_type'), inserter_type: realm.setting('inserter_type'))
gen.call
book.add_blueprint_decoded(gen.blueprint_json)

gen = StationRequester.new(item, belts_type: realm.setting('belts_type'), inserter_type: realm.setting('inserter_type'))
gen.call
book.add_blueprint_decoded(gen.blueprint_json)

gen = StationTrain.new(item, belts_type: realm.setting('belts_type'), inserter_type: realm.setting('inserter_type'))
gen.call
book.add_blueprint_decoded(gen.blueprint_json)

if ARGV[1] == 'p'
  gen = StationProvider.new(item, belts_type: realm.setting('belts_type'), inserter_type: realm.setting('inserter_type'), priority: -1)
  gen.call
  book.add_blueprint_decoded(gen.blueprint_json)

  gen = StationProvider.new(item, belts_type: realm.setting('belts_type'), inserter_type: realm.setting('inserter_type'), priority: 1)
  gen.call
  book.add_blueprint_decoded(gen.blueprint_json)

  gen = StationRequester.new(item, belts_type: realm.setting('belts_type'), inserter_type: realm.setting('inserter_type'), priority: -1)
  gen.call
  book.add_blueprint_decoded(gen.blueprint_json)
end

result = book.blueprint
begin
  IO.popen('pbcopy', 'w') { |f| f << result }
  puts 'Copied to clipboard'
rescue StandardError => e
  puts "Clipboard error: #{e.message}"
  puts result
end

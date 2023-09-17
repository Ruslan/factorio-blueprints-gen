require 'base64'
require 'json'
require 'zlib'
require 'optparse'

require './lib/item.rb'
require './lib/realm.rb'
require './lib/items.rb'
require './lib/blueprint_generator.rb'
require './lib/blueprint_book.rb'
require './lib/station_provider.rb'
require './lib/station_requester.rb'
require './lib/station_train.rb'

require 'pry'

options = { realm: 'default' }
OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on("-p", "--priorities", "Add priorities blueprints") do |v|
    options[:priorities] = true
  end

  opts.on("-r Realm", "--realm Realm", "Set realm") do |v|
    options[:realm] = v
  end

  opts.on("-l", "--landfill", "Lay landfill") do |v|
    options[:landfill] = v
  end
end.parse!

resource = ARGV[0]
unless resource&.size&.positive?
  puts "usage: main.rb ITEMNAME"
  return
end

realm_path = Dir.glob('realms/*.yml').find { |r| r == "realms/#{options[:realm]}.yml" }
unless realm_path
  puts "Realm not found: #{options[:realm]}"
  exit
end

realm = Realm.new(realm_path)
item = Items.new(realm).find(resource)

bp_opts = {
  belts_type: realm.setting('belts_type'),
  inserter_type: realm.setting('inserter_type'),
  landfill: options[:landfill]
}

puts "~~~~[#{item.name}]~~~~"
puts

# DEBUG
gen = StationRequester.new(item, bp_opts.merge(priority: -1))
gen.call
puts JSON.pretty_generate(gen.blueprint_json)
puts gen.blueprint
exit
# END

book = BlueprintBook.new

gen = StationProvider.new(item, bp_opts)
gen.call
book.add_blueprint_decoded(gen.blueprint_json)

gen = StationRequester.new(item, bp_opts)
gen.call
book.add_blueprint_decoded(gen.blueprint_json)

gen = StationTrain.new(item, bp_opts)
gen.call
book.add_blueprint_decoded(gen.blueprint_json)

if options[:priorities]
  gen = StationProvider.new(item, bp_opts.merge(priority: -1))
  gen.call
  book.add_blueprint_decoded(gen.blueprint_json)

  gen = StationProvider.new(item, bp_opts.merge(priority: 1))
  gen.call
  book.add_blueprint_decoded(gen.blueprint_json)

  gen = StationRequester.new(item, bp_opts.merge(priority: -1))
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

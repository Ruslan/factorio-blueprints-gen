require 'base64'
require 'json'
require 'zlib'
require 'optparse'
require 'bigdecimal'

require './lib/item.rb'
require './lib/realm.rb'
require './lib/items.rb'
require './lib/blueprint_generator.rb'
require './lib/blueprint_book.rb'
require './lib/station_provider.rb'
require './lib/station_requester.rb'
require './lib/station_train.rb'
require './lib/landing_pad.rb'
require './lib/rocket_silo.rb'

require 'pry'

options = { realm: 'default', landing_pad: true, landfill: true, priorities: true, train_capacity: -1 }
OptionParser.new do |opts|
  opts.banner = "Usage: main.rb [options]"

  opts.on("-p", "--priorities true", "Add priorities blueprints") do |v|
    options[:priorities] = v != 'false'
  end

  opts.on("-r Realm", "--realm Realm", "Set realm") do |v|
    options[:realm] = v
  end

  opts.on("-l", "--landfill", "Add landfill") do |v|
    options[:landfill] = v
  end

  opts.on("--test", "Test run") do |v|
    options[:test] = v != 'false'
  end

  opts.on("--landing-pad false", "Add landing pad") do |v|
    options[:landing_pad] = v != 'false'
  end

  opts.on("-c 1", "--capacity 1", "What part of train (1/C) transferred at time. Good for compact and expensive goods") do |v|
    options[:train_capacity] = 1 / BigDecimal(v)
  end

end.parse!

p options

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

default_realm = Realm.new('realms/default.yml')
realm = Realm.new(realm_path, default_realm)
item = Items.new(realm).find(resource)

bp_opts = {
  belts_type: realm.setting('belts_type'),
  inserter_type: realm.setting('inserter_type'),
  landfill: options[:landfill],
  train_capacity: options[:train_capacity]
}

puts "~~~~[#{item.name}]~~~~"
puts

if options[:test]
  gen = StationRequester.new(item, bp_opts.merge(priority: -1))
  gen.call
  puts JSON.pretty_generate(gen.blueprint_json)
  puts gen.blueprint
  exit
end

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
  if !options[:landing_pad]
    gen.priority_low_icon = 'signal-L'
    gen.priority_high_icon = 'signal-H'
  end
  gen.call
  book.add_blueprint_decoded(gen.blueprint_json)

  gen = StationProvider.new(item, bp_opts.merge(priority: 1))
  if !options[:landing_pad]
    gen.priority_low_icon = 'signal-L'
    gen.priority_high_icon = 'signal-H'
  end
  gen.call
  book.add_blueprint_decoded(gen.blueprint_json)

  gen = StationRequester.new(item, bp_opts.merge(priority: -1))
  if !options[:landing_pad]
    gen.priority_low_icon = 'signal-L'
    gen.priority_high_icon = 'signal-H'
  end
  gen.call
  book.add_blueprint_decoded(gen.blueprint_json)
end

if options[:landing_pad] && item.type == 'item'
  gen = LandingPad.new(item, bp_opts)
  gen.call
  book.add_blueprint_decoded(gen.blueprint_json)

  gen = RocketSilo.new(item, bp_opts)
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

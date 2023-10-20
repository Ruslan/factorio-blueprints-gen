require 'set'
require 'json'

# items = Set.new

# Dir.glob('templates/*').each do |f|
#   File.read(f).scan(/"name": ?"([^"]+)"/).each do |a, b|
#     items << a
#   end
# end

# puts items.sort

items = %w(
arithmetic-combinator
cargo-wagon
constant-combinator
decider-combinator
express-splitter
express-transport-belt
express-underground-belt
locomotive
medium-electric-pole
pipe
pipe-to-ground
pump
rail
rail-signal
small-lamp
stack-inserter
steel-chest
storage-tank
train-stop
big-electric-pole
logistic-chest-requester
logistic-chest-buffer
logistic-chest-active-provider
stack-filter-inserter
substation
rail-chain-signal
cargo-wagon
fluid-wagon
logistic-robot
construction-robot
se-rocket-launch-pad
se-rocket-landing-pad
se-electric-boiler
nuclear-reactor
heat-pipe
heat-exchanger
se-condenser-turbine
steam-turbine
area-mining-drill
offshore-pump
pumpjack
se-core-miner
electric-furnace
industrial-furnace
se-casting-machine
se-recycling-facility
se-pulveriser
assembling-machine-3
oil-refinery
chemical-plant
se-lifesupport-facility
se-fuel-refinery
centrifuge
beacon
effectivity-module
se-meteor-defence
se-meteor-defence-ammo
se-energy-beam-defence
)

# speed-module-3
# productivity-module-3

@recipes = JSON.parse(File.read('external-data/recipe.json'))

@recipes.each do |n, r|
  if r['ingredients'].find { |i| i['name'] == ARGV[0] }
    puts n
  end
end
exit
@source_products = %w(copper-plate iron-plate steel-plate water plastic-bar heavy-oil se-vulcanite-block solid-fuel sulfur)
@source_products += %w(electronic-circuit advanced-circuit electric-motor)

def explain(item, level = 0, trace = [])
  puts "#{"\t" * level}#{item}"
  if trace.include?(item)
    puts "#{"\t" * (level + 1)}+"
    return nil
  end
  if @source_products.include?(item)
    puts "#{"\t" * (level + 1)}+"
    return item
  end
  rec = @recipes.values.find { |v| v.dig('main_product', 'name') == item }
  if rec
    rec['ingredients'].map do |i|
      explain(i['name'], level + 1, trace + [item])
    end
  else
    puts "#{"\t" * (level + 1)}?"
    return item
  end
end

all_items = Set.new
items = items.uniq.sort
items.each do |item|
  result = explain(item)
  ingredients = result.flatten.uniq.compact
  all_items += ingredients
  puts "#{item}=#{ingredients.join(' ')}"
  puts '______'
end

puts "hub input:"
puts all_items.to_a

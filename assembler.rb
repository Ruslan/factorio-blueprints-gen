require 'base64'
require 'json'
require 'zlib'
require 'optparse'
require 'pry'
require './lib/blueprint_generator.rb'
require './lib/assembler.rb'

@recipes = JSON.parse(File.read('external-data/recipe.json'))

options = {
  limit: 50,
  lr: 10,
  assembler: 'assembling-machine-3',
  modules: 'productivity-module-3',
  modules_count: 4
}

OptionParser.new do |opts|
  opts.banner = "Usage: assembler.rb [options]"

  opts.on("-l 100", "--limit 100", "Limit of output") do |v|
    options[:limit] = v.to_i
  end

  opts.on("-L 10", "--limit-to-request 10", "Limit to request ratio (default 10)") do |v|
    options[:lr] = v.to_i
  end

  opts.on("-a se-space-assembling-machine", "--assembler se-space-assembling-machine", "Assembler item name") do |v|
    options[:assembler] = v
  end

  opts.on("-m productivity-module-3", "--modules=productivity-module-3", "Assembler modules") do |v|
    options[:modules] = v
  end

  opts.on("-mc", "--modules-count", "Assembler modules count") do |v|
    options[:modules_count] = v
  end
end.parse!


p options

item_name = ARGV[0]
item_names = Regexp.new(item_name.split('%').join('.*'))
variants = []
@recipes.each do |k, v|
  key = v.dig('main_product', 'name')
  if item_names.match?(key)
    variants << key
  end
end

if variants.size > 1
  puts "Please select:"
  variants.each.with_index do |v, i|
    puts "\t#{i}) #{v}"
  end
  index = $stdin.gets.chomp
  item_name = variants[index.to_i]
elsif variants.size == 1
  item_name = variants.first
else
  puts "not found"
  exit
end

puts "====#{item_name}===="
@recipes[item_name]['ingredients'].each do |i|
  if i['type'] == 'item'
    puts "\t#{i['name']} x #{i['amount']}"
  else
    puts "\t!!![#{i['type']}]#{i['name']} x #{i['amount']}"
  end
end

# pp @recipes[item_name]

gen = Assembler.new(@recipes[item_name], options)
gen.call
# puts JSON.pretty_generate(gen.blueprint_json)
result = gen.blueprint

begin
  IO.popen('pbcopy', 'w') { |f| f << result }
  puts 'Copied to clipboard'
rescue StandardError => e
  puts "Clipboard error: #{e.message}"
  puts result
end

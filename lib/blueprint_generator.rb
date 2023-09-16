require 'erb'

class BlueprintGenerator
  def initialize
    @result = {
      entities: [],
      item: :blueprint,
      version: 281479277379584
    }
    @icons = []
    @template = JSON.parse(File.read("templates/#{template_name}.json"))['blueprint']['entities']
  end

  def blueprint_json
    {
      blueprint: @result
    }
  end

  def blueprint
    '0' + Base64.encode64(Zlib::Deflate.deflate(blueprint_json.to_json))
  end

  def call
    setup_icons
  end

  def setup_icons
    @result['icons'] = @icons.map.with_index do |item_code, index|
      type, name = item_code.gsub(/[\[\]]/, '').split('=')
      {
        signal: {
          type: type,
          name: name
        },
        index: index + 1
      }
    end
  end

  def copy_entities(names: [], &block)
    entities = @template.select { |e| names.include?(e['name']) }
    entities = entities.map(&block) if block_given?
    add_entities(entities)
  end

  def add_entities(list)
    @result[:entities] += list
  end
end

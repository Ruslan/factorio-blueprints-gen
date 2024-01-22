require 'erb'

class BlueprintGenerator
  def initialize
    filename = if @mod && File.exists?("templates/#{template_name}_#{@mod}.json")
      "templates/#{template_name}_#{@mod}.json"
    else
      "templates/#{template_name}.json"
    end
    @template_base = JSON.parse(File.read(filename))['blueprint']
    @icons = []
    @template = @template_base.delete('entities')
    @result = @template_base.merge('entities' => [])
  end

  def blueprint_json
    {
      'blueprint' => @result
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
      type.gsub!('-signal', '')
      {
        'signal' => {
          'type' => type,
          'name' => name
        },
        'index' => index + 1
      }
    end
    @result['label'] = @icons.join('')
  end

  def copy_entities(names: [], &block)
    entities = @template.select { |e| names.include?(e['name']) }
    entities = entities.map(&block) if block_given?
    add_entities(entities)
  end

  def add_entities(list)
    @result['entities'] += list
  end

  def add_tiles(list)
    @result['tiles'] ||= []
    @result['tiles'] += list
  end
end

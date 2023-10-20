class Assembler < BlueprintGenerator
  # Priority: 1 = take first, -1 = take last, 0 = no control
  def initialize(recipe, options)
    @recipe = recipe
    @options = options
    super()
  end

  def call
    build_icons
    super
    copy_entities(names: %w(assembling-machine-3)) do |e|
      e['name'] = @options[:assembler]
      e['recipe'] = @recipe['name']
      e['items'] = { @options[:modules] => @options[:modules_count] }
      e
    end

    copy_entities(names: %w(stack-inserter)) do |e|
      e['position']['y'] += 3 if @options[:assembler] == 'se-space-manufactory'
      next e unless e['control_behavior']

      e['control_behavior']['circuit_condition']['first_signal']['name'] = @recipe['main_product']['name']
      e['control_behavior']['circuit_condition']['constant'] = @options[:limit]
      e
    end

    copy_entities(names: %w(logistic-chest-requester)) do |e|
      e['request_filters'] = @recipe['ingredients'].filter_map.with_index do |ing, i|
        if ing['type'] == 'item'
          { index: i + 1, name: ing['name'], count: ing['amount'] * @options[:limit] / @options[:lr] }
        end
      end
      e['position']['y'] += 3 if @options[:assembler] == 'se-space-manufactory'
      e
    end

    copy_entities(names: %w(logistic-chest-storage)) do |e|
      e['request_filters'][0]['name'] = @recipe['main_product']['name']
      e['position']['y'] += 3 if @options[:assembler] == 'se-space-manufactory'
      e
    end
  end

  def build_icons
    @icons = ["[item=#{@options[:assembler]}]", "[#{@recipe['main_product']['type']}=#{@recipe['main_product']['name']}]"]
  end

  def template_name
    'assembler'
  end
end

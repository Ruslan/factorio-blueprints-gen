class StationProvider < BlueprintGenerator
  # Priority: 1 = take first, -1 = take last, 0 = no control
  def initialize(item, train_limit: 2, belts_type: 'express', inserter_type: 'stack', priority: 0, landfill: false)
    @belts_type = belts_type
    @inserter_type = inserter_type

    @item = item
    @item_name = item.name
    @stack_size = item.stack_size
    @train_capacity = item.train_capacity
    @trains_store = item.trains_store
    @item_type = item.type

    @priority = priority
    @train_limit = train_limit
    @landfill = landfill

    super()
  end

  def call
    build_icons
    super
    setup_belts
    setup_inserters
    setup_base
    setup_combinator
    setup_stop
    setup_priority
    finalize_entities
    setup_landfill if @landfill
  end

  def finalize_entities
    shift_belts_for_space if @belts_type.to_s == 'se-space' && @item_type == 'item'
  end

  def setup_belts
    copy_entities(names: %w(express-splitter express-transport-belt express-underground-belt)) do |belt|
      case @belts_type.to_s
      when 'fast'
        belt['name'].gsub!('express-', 'fast-')
      when 'slow'
        belt['name'].gsub!('express-', '')
      when 'se-space'
        belt['name'].gsub!('express-', 'se-space-')
      end
      belt
    end
  end

  def setup_inserters
    copy_entities(names: %w(inserter stack-inserter stack-filter-inserter)) do |inserter|
      case @inserter_type
      when 'fast'
        belt['name'].gsub!('stack-', 'fast-')
      end
      inserter
    end
  end

  def setup_base
    copy_entities(names: %w(small-lamp steel-chest medium-electric-pole rail-signal storage-tank pump substation logistic-chest-storage logistic-chest-active-provider logistic-chest-requester))
    copy_entities(names: %w(pipe pipe-to-ground)) do |pipe|
      case @belts_type.to_s
      when 'se-space-transport'
        pipe['name'] = "se-space-#{pipe['name']}"
      end
      pipe
    end
  end

  def setup_combinator
    copy_entities(names: %w(constant-combinator arithmetic-combinator decider-combinator)) do |comb|
      case comb['name']
      when 'constant-combinator'
        case comb.dig('control_behavior', 'filters', 0, 'signal', 'name')
        when 'signal-M'
          comb['control_behavior']['filters'][0]['count'] = @train_limit
        end
      when 'arithmetic-combinator'
        case comb.dig('control_behavior', 'arithmetic_conditions', 'output_signal', 'name')
        when 'signal-D'
          comb['control_behavior']['arithmetic_conditions']['second_constant'] = train_items_count
        end
      end
      comb
    end
  end

  def setup_stop
    copy_entities(names: %w(train-stop)) do |stop|
      stop['station'] = "[#{@item_type}=#{@item_name}][item=logistic-chest-passive-provider]"
      stop
    end
  end

  def setup_priority
    return unless @priority.abs > 0

    stop = @result['entities'].find { |e| e['name'] == 'train-stop' }
    return unless stop

    case @priority
    when 1
      lowest_pole = @result['entities'].select { |e| e['name'] == 'medium-electric-pole' }.sort_by { |e| e['position']['y'] }.last
      return unless lowest_pole

      limit = train_items_count

      json = ERB.new(File.read('templates/_station_priority_1.json.erb')).result(binding)
    when -1
      decider = @result['entities'].select { |e| e['name'] == 'decider-combinator' && e.dig('control_behavior', 'decider_conditions', 'first_signal', 'name') == 'signal-D' && e.dig('control_behavior', 'decider_conditions', 'second_signal', 'name') == 'signal-M' && e.dig('control_behavior', 'decider_conditions', 'output_signal', 'name') == 'signal-D' }
      return raise StandardError, "no decider: found #{decider.size}" unless decider.size == 1

      decider = decider.first

      item_type = @item_type
      item_name = @item_name

      json = ERB.new(File.read('templates/_station_priority_-1.json.erb')).result(binding)
    end
    add_entities(JSON.parse(json))
  end

  def setup_landfill
    landfills = []
    landfill_name = @item.realm.setting('landfill')
    @result['entities'].each do |e|
      next if landfill_name =~ /^se-/ && (%w(rail-signal)).include?(e['name'])
      width = 1
      height = 1
      case e['name']
      when 'storage-tank'
        width = 3
        height = 3
      when 'substation', 'pump', 'arithmetic-combinator', 'decider-combinator', 'train-stop', /splitter/  # TODO: add rotation support for 2x1
        width = 2
        height = 2
      when 'se-rocket-landing-pad'
        width = 9
        height = 9
      end
      x0 = (e['position']['x'] - (width - 1) / 2.0).floor
      x1 = (e['position']['x'] + (width - 1) / 2.0).floor
      y0 = (e['position']['y'] - (height - 1) / 2.0).floor
      y1 = (e['position']['y'] + (height - 1) / 2.0).floor
      x0.upto(x1) do |x|
        y0.upto(y1) do |y|
          landfills << [x, y]
        end
      end
    end
    landfills = landfills.uniq.map do |x, y|
      { 'position' => { 'x' => x, 'y' => y }, 'name' => landfill_name }
    end
    add_tiles(landfills)
  end

  def build_icons
    @icons = ['[item=train-stop]', "[#{@item_type}=#{@item_name}]", '[item=logistic-chest-passive-provider]']
    @icons << "[virtual-signal=se-nav-arrow-left-down]" if @priority == -1
    @icons << "[virtual-signal=se-nav-arrow-left-up]" if @priority == 1
  end

  def template_name
    case @item_type
    when 'fluid'
      'station_provider_fluid'
    else
      'station_provider'
    end
  end

  def train_items_count
    case @item_type
    when 'fluid'
      (@stack_size * 4 * @train_capacity).ceil
    else
      (@stack_size * 40 * 4 * @train_capacity).ceil
    end
  end

  def station_items_count
    case @item_type
    when 'fluid'
      @stack_size * 5
    else
      (@stack_size * 48 * 6 * 4).ceil
    end
  end

  def shift_belts_for_space
    belts = JSON.parse(File.read("templates/_se_space_provider_belts.json"))['blueprint']['entities']
    belt_names = %w(se-space-underground-belt se-space-transport-belt se-space-splitter)
    top_lamp = @result['entities'].select { |e| e['name'] == 'small-lamp' }.min_by { |e| e['position']['y'] }
    belts_top_lamp = belts.select { |e| e['name'] == 'small-lamp' }.min_by { |e| e['position']['y'] }
    dx = belts_top_lamp['position']['x'] - top_lamp['position']['x']
    dy = belts_top_lamp['position']['y'] - top_lamp['position']['y']
    belts.each do |belt|
      belt['entity_number'] += 976800
      belt['position']['x'] -= dx
      belt['position']['y'] -= dy
    end

    @result['entities'] = @result['entities'].reject { |e| belt_names.include?(e['name']) && e['position']['y'] <= top_lamp['position']['y'] }

    add_entities(belts.select { |e| belt_names.include?(e['name']) })
  end
end

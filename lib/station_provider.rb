class StationProvider < BlueprintGenerator
  # Priority: 1 = take first, -1 = take last, 0 = no control
  def initialize(item, train_limit: 2, belts_type: 'express', inserter_type: 'stack', priority: 0)
    super()

    @belts_type = belts_type
    @inserter_type = inserter_type

    @item = item
    @item_name = item.name
    @stack_size = item.stack_size
    @train_capacity = item.train_capacity
    @trains_store = item.trains_store

    @priority = priority
    @train_limit = train_limit
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
  end

  def setup_belts
    copy_entities(names: %w(express-splitter express-transport-belt express-underground-belt)) do |belt|
      case @belts_type.to_s
      when 'fast'
        belt['name'].gsub!('express-', 'fast-')
      when 'slow'
        belt['name'].gsub!('express-', '')
      end
      belt
    end
  end

  def setup_inserters
    copy_entities(names: %w(stack-inserter)) do |inserter|
      case @inserter_type
      when 'fast'
        belt['name'].gsub!('stack-', 'fast-')
      end
      inserter
    end
  end

  def setup_base
    copy_entities(names: %w(small-lamp steel-chest medium-electric-pole rail-signal))
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
      stop['station'] = "[item=#{@item_name}][item=logistic-chest-passive-provider]"
      stop
    end
  end

  def setup_priority
    return unless @priority.abs > 0

    stop = @result[:entities].find { |e| e['name'] == 'train-stop' }
    return unless stop

    case @priority
    when 1
      lowest_pole = @result[:entities].select { |e| e['name'] == 'medium-electric-pole' }.sort_by { |e| e['position']['y'] }.last
      return unless lowest_pole

      limit = train_items_count

      json = ERB.new(File.read('templates/_station_priority_1.json.erb')).result(binding)
    when -1
      decider = @result[:entities].select { |e| e['name'] == 'decider-combinator' && e.dig('control_behavior', 'decider_conditions', 'first_signal', 'name') == 'signal-D' && e.dig('control_behavior', 'decider_conditions', 'second_signal', 'name') == 'signal-M' && e.dig('control_behavior', 'decider_conditions', 'output_signal', 'name') == 'signal-D' }
      return raise StandardError, "no decider: found #{decider.size}" unless decider.size == 1

      decider = decider.first

      item_name = @item_name

      json = ERB.new(File.read('templates/_station_priority_-1.json.erb')).result(binding)
    end
    add_entities(JSON.parse(json))
  end

  def build_icons
    @icons = ['[item=train-stop]', "[item=#{@item_name}]", '[item=logistic-chest-passive-provider]']
  end

  def template_name
    'station_provider'
  end

  def train_items_count
    (@stack_size * 40 * 4 * @train_capacity).ceil
  end

  def station_items_count
    (@stack_size * 48 * 6 * 4).ceil
  end
end

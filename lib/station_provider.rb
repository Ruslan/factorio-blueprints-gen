class StationProvider < BlueprintGenerator
  def initialize(item, train_limit: 2, belts_type: 'express', inserter_type: 'stack')
    super()

    @belts_type = belts_type
    @inserter_type = inserter_type

    @item = item
    @item_name = item.name || "[virtual-signal=signal-info]"
    @stack_size = item.stack_size
    @train_capacity = item.train_capacity
    @trains_store = item.trains_store

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
      stop['station'] = "#{@item_name}[item=logistic-chest-passive-provider]"
      stop
    end
  end

  def build_icons
    @icons = ['[item=train-stop]', @item_name, '[item=logistic-chest-passive-provider]']
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

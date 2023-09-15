class StationProvider < BlueprintGenerator
  def initialize
    super

    @item_name = "[virtual-signal=signal-info]"
    @belts_type = 'express'
    @stack_size = 50
    @train_capacity = 1.0

    @train_limit = 2
  end

  attr_accessor :belts_type, :inserter_type, :item_name, :stack_size, :train_capacity, :train_limit

  def call
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
          comb['control_behavior']['arithmetic_conditions']['second_constant'] = (@stack_size * 40 * 4 * @train_capacity).ceil
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

  def template_name
    'station_provider'
  end
end

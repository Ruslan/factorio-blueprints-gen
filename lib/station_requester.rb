class StationRequester < StationProvider
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
      stop['station'] = "#{@item_name}[item=logistic-chest-passive-requester]"
      stop
    end
  end

  def template_name
    'station_requester'
  end
end

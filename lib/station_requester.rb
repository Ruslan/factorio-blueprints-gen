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
        case comb.dig('control_behavior', 'arithmetic_conditions', 'operation')
        when '-'
          comb['control_behavior']['arithmetic_conditions']['first_constant'] = station_items_count
        when '/'
          comb['control_behavior']['arithmetic_conditions']['second_constant'] = train_items_count
        end
      end
      comb
    end
  end

  def setup_stop
    copy_entities(names: %w(train-stop)) do |stop|
      stop['station'] = "#{@item_name}[item=logistic-chest-requester]"
      stop
    end
  end

  def build_icons
    @icons = ['[item=train-stop]', @item_name, '[item=logistic-chest-requester]']
  end

  def template_name
    'station_requester'
  end

  def station_items_count
    max_count = (@stack_size * 48 * 4 * 4).ceil
    [train_items_count * @trains_store, max_count].min
  end
end

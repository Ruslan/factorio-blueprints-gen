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
      stop['station'] = "[#{@item_type}=#{@item_name}][item=logistic-chest-requester]"
      stop
    end
  end

  def build_icons
    @icons = ['[item=train-stop]', "[#{@item_type}=#{@item_name}]", '[item=logistic-chest-requester]']
    @icons << "[virtual-signal=se-nav-arrow-left-down]" if @priority == -1
    @icons << "[virtual-signal=se-nav-arrow-left-up]" if @priority == 1
  end

  def setup_priority
    return unless @priority.abs > 0

    stop = @result['entities'].find { |e| e['name'] == 'train-stop' }
    return unless stop

    case @priority
    when -1
      constant = @result['entities'].select { |e| e['name'] == 'constant-combinator' && e.dig('control_behavior', 'filters', 0, 'signal', 'name') == 'signal-M' }
      return raise StandardError, "no constant M: found #{constant.size}" unless constant.size == 1

      constant = constant.first
      constant['control_behavior']['filters'][0]['count'] = 0

      item_type = @item_type
      item_name = @item_name
      extra_count_on = case @item.type
      when 'fluid'
        25000
      else
        train_items_count
      end

      json = ERB.new(File.read('templates/_station_priority_-1_req.json.erb')).result(binding)
    end
    add_entities(JSON.parse(json)) if json
  end

  def template_name
    case @item_type
    when 'fluid'
      'station_requester_fluid'
    else
      'station_requester'
    end
  end

  def station_items_count
    max_count = case @item_type
    when 'fluid'
      @stack_size * 5
    else
      (@stack_size * 48 * 4 * 4).ceil
    end
    [train_items_count * @trains_store, max_count].min
  end
end

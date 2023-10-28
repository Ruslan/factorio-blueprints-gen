class LandingPad < StationProvider
  def setup_combinator
  end

  def setup_stop
    copy_entities(names: %w(se-rocket-landing-pad)) do |entity|
      entity['tags'] = {
        'name' => "[img=#{@item_type}.#{@item_name}]"
      }
      entity
    end
  end

  def finalize_entities
    @result['entities'].each do |e|
      if e['filters']&.any?
        e['filters'][0]['name'] = @item_name
      elsif e['request_filters']&.any?
        e['request_filters'][0]['name'] = @item_name
      end
    end
  end

  def build_icons
    @icons = ['[item=se-rocket-landing-pad]', "[#{@item_type}=#{@item_name}]", '[item=logistic-chest-requester]']
  end

  def setup_priority
  end

  def template_name
    'landing_pad'
  end

  def station_items_count
  end

  def shift_belts_for_space
  end
end

class RocketSilo < StationProvider
  def setup_combinator
  end

  def setup_stop
    copy_entities(names: %w(se-rocket-launch-pad)) do |entity|
      entity['tags'] = {
        'landing_pad_name' => "[img=#{@item_type}.#{@item_name}]",
          "launch_trigger": "cargo-full",
          "name": "Provider of [img=#{@item_type}.#{@item_name}]"
      }
      entity
    end
  end

  def finalize_entities
  end

  def build_icons
    @icons = ['[item=se-rocket-launch-pad]', "[#{@item_type}=#{@item_name}]", '[item=logistic-chest-active-provider]']
  end

  def setup_priority
  end

  def template_name
    'rocket_silo'
  end

  def station_items_count
  end

  def shift_belts_for_space
  end
end

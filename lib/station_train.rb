class StationTrain < StationProvider
  def call
    super
    setup_schedule
  end

  def setup_base
    copy_entities(names: %w(cargo-wagon fluid-wagon locomotive)) do |wagon|
      wagon['name'] = 'fluid-wagon' if @item.type == 'fluid' && wagon['name'] == 'cargo-wagon'
      wagon
    end
  end

  def setup_schedule
    template = JSON.parse(File.read("templates/#{template_name}.json"))['blueprint']['schedules']
    template[0]['schedule'][0]['station'] = "[#{@item_type}=#{@item_name}][item=logistic-chest-passive-provider]"
    template[0]['schedule'][1]['station'] = "[#{@item_type}=#{@item_name}][item=logistic-chest-requester]"
    if @train_capacity == 1
      template[0]['schedule'][0]['wait_conditions'][0] = {
        compare_type: :or,
        type: :full
      }
    else
      template[0]['schedule'][0]['wait_conditions'][0]['type'] = 'fluid_count' if @item_type == 'fluid'
      template[0]['schedule'][0]['wait_conditions'][0]['condition']['first_signal']['type'] = @item_type
      template[0]['schedule'][0]['wait_conditions'][0]['condition']['first_signal']['name'] = @item_name
      template[0]['schedule'][0]['wait_conditions'][0]['condition']['constant'] = train_items_count
    end
    @result['schedules'] = template
  end

  def build_icons
    @icons = ['[item=train-stop]', "[#{@item_type}=#{@item_name}]", '[item=locomotive]']
  end

  def template_name
    'station_train'
  end
end

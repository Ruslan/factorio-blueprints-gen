class StationTrain < StationProvider
  def call
    super
    setup_schedule
  end

  def setup_base
    copy_entities(names: %w(cargo-wagon locomotive))
  end

  def setup_schedule
    template = JSON.parse(File.read("templates/#{template_name}.json"))['blueprint']['schedules']
    template[0]['schedule'][0]['station'] = "[item=#{@item_name}][item=logistic-chest-passive-provider]"
    template[0]['schedule'][1]['station'] = "[item=#{@item_name}][item=logistic-chest-requester]"
    if @train_capacity == 1
      template[0]['schedule'][0]['wait_conditions'][0] = {
        compare_type: :or,
        type: :full
      }
    else
      template[0]['schedule'][0]['wait_conditions'][0]['condition']['first_signal']['name'] = @item_name
      template[0]['schedule'][0]['wait_conditions'][0]['condition']['constant'] = train_items_count
    end
    @result['schedules'] = template
  end

  def build_icons
    @icons = ['[item=train-stop]', "[item=#{@item_name}]", '[item=locomotive]']
  end

  def template_name
    'station_train'
  end
end

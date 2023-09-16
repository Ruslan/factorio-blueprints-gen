class BlueprintBook
  def initialize
    @result = {
      "blueprint_book" => {
        "blueprints" => [
        ],
        "item" => "blueprint-book",
        "label" => nil,
        "active_index" => 0,
        "version" => 281479277379584
      }
    }
  end

  def add_blueprint_decoded(data)
    @result['blueprint_book']['blueprints'] << data.merge('index' => @result['blueprint_book']['blueprints'].size)
    @result['blueprint_book']['label'] ||= data['blueprint']['icons'][0..1].map do |icon|
      "[#{icon['signal']['type']}=#{icon['signal']['name']}]"
    end.join
  end

  def blueprint
    '0' + Base64.encode64(Zlib::Deflate.deflate(@result.to_json))
  end
end

class Items
  def initialize(realm)
    @items = realm.items
    @realm = realm
  end

  def find(item_name)
    key, value = find_item_tuple(item_name)
    return unless key

    item = Item.new
    item.realm = @realm
    item.name = key
    value.each do |k, v|
      item.send("#{k}=", v)
    end
    item
  end

  def find_item_tuple(item_name)
    return [item_name, @items[item_name]] if @items[item_name]
    variants = []
    @items.each do |key, item|
      if key.include?(item_name)
        variants << key
      end
    end
    if variants.size > 1
      puts "Please select:"
      variants.each.with_index do |v, i|
        puts "\t#{i}) #{v}"
      end
      index = gets.chomp
      item_name = variants[index.to_i]
      [item_name, @items[item_name]]
    elsif variants.size == 1
      item_name = variants.first
      [item_name, @items[item_name]]
    else
      [nil, nil]
    end
  end
end

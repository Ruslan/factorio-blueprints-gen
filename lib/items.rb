class Items
  def initialize(file)
    @repo = JSON.parse(File.read(file))
  end

  def find(item_name)
    item_json = @repo['items'].find { |item| item['name'] == item_name }
    item = Item.new
    item.name = item_json['name']
    item.stack_size = item_json['stack_size']
    item.train_capacity = item_json['train_capacity']
    item.trains_store = item_json['trains_store']
    item
  end
end

class Item
  attr_accessor :name, :stack_size, :train_capacity, :trains_store

  def initialize
    @stack_size = 50
    @train_capacity = 1
    @trains_store = 2.5
  end
end

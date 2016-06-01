class AddStateToProducts < ActiveRecord::Migration
  def change
    add_column :products, :state, :integer, default: 0
    add_column :products, :product_size, :string
    add_column :products, :origin, :string
  end
end

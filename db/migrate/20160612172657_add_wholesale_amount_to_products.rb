class AddWholesaleAmountToProducts < ActiveRecord::Migration
  def change
    add_column :products, :wholesale_amount, :integer, default: 1
    add_column :products, :price_in_name, :boolean, default: false
  end
end

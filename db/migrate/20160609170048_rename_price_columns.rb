class RenamePriceColumns < ActiveRecord::Migration
  def change
    rename_column :order_items, :price, :ordered_price
    add_column :order_items, :item_code, :string
    remove_column :cart_items, :price
    remove_column :cart_items, :item_code
    remove_column :cart_items, :name
  end
end

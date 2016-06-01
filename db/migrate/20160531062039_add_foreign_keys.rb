class AddForeignKeys < ActiveRecord::Migration
  def change
    add_foreign_key :carts, :users
    add_foreign_key :cart_items, :carts
    add_foreign_key :cart_items, :products
  end
end

class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.references :cart, index: true
      t.references :product
      t.string :item_code
      t.string :name
      t.integer :price
      t.integer :quantity

      t.timestamps null: false
    end
  end
end

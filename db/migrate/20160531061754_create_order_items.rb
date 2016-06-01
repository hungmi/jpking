class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.references :order, index: true, foreign_key: true
      t.references :product, index: true, foreign_key: true
      # t.references :cart_item, index: true#, foreign_key: true
      t.string :name
      t.integer :quantity
      t.integer :price
      t.integer :state

      t.timestamps null: false
    end
  end
end

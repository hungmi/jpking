class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :category, index: true, foreign_key: true
      t.string :jp_name
      t.string :zh_name
      t.integer :original_price
      t.integer :wholesale_price
      t.integer :stock
      t.string :item_code

      t.timestamps null: false
    end
  end
end

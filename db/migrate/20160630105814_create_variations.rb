class CreateVariations < ActiveRecord::Migration
  def change
    create_table :variations do |t|
      t.string :item_code
      t.references :product, index: true, foreign_key: true
      t.string :zh_name
      t.string :jp_name
      t.string :gtin_code

      t.timestamps null: false
    end
  end
end

class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.references :shop, index: true, foreign_key: true
      t.references :parent, index: true
      t.integer :total
      t.string :jp_name
      t.string :zh_name
      t.string :code
      t.string :tipe

      t.timestamps null: false
    end
  end
end

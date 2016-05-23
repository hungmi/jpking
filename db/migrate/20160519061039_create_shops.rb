class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.string :zh_name
      t.string :jp_name

      t.timestamps null: false
    end
  end
end

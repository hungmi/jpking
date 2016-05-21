class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :value
      t.date :fetch_time
      t.integer :state, default: 0
      t.references :fetchable, polymorphic: true, index: true

      t.timestamps null: false
    end
  end
end

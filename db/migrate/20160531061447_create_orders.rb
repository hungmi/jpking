class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :token
      t.string :num
      # t.references :cart, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.integer :total
      t.integer :delivery
      t.integer :state, default: 0

      t.timestamps null: false
    end
  end
end

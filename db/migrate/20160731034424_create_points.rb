class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.integer :value
      t.references :user, index: true
      t.belongs_to :order_item, index: true
      t.references :order, index: true
      t.string :coupon_code
      t.integer :reason

      t.timestamps null: false
    end
  end
end

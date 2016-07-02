class CreateSettings < ActiveRecord::Migration
  def change
    create_table :settings do |t|
      t.decimal :currency, precision: 6, scale: 4
      t.decimal :tax_factor, precision: 6, scale: 4
      t.decimal :benefit_factor, precision: 6, scale: 4

      t.timestamps null: false
    end
  end
end

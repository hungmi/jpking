class AddColumnToProducts < ActiveRecord::Migration
  def change
    add_column :products, :platform, :integer
    add_column :products, :special_price, :integer
    add_column :products, :weight, :decimal, precision: 10, scale: 3
  end
end

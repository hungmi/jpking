class AddVariationsCountToProducts < ActiveRecord::Migration
  def change
    add_column :products, :variations_count, :integer, default: 0
  end
end

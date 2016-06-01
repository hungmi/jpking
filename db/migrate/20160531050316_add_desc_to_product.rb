class AddDescToProduct < ActiveRecord::Migration
  def change
    add_column :products, :material, :text
    add_column :products, :description, :text
  end
end

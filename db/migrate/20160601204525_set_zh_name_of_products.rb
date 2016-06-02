class SetZhNameOfProducts < ActiveRecord::Migration
  def change
    change_column :products, :zh_name, :string, default: ""
  end
end

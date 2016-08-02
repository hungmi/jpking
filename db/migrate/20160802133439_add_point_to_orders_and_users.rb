class AddPointToOrdersAndUsers < ActiveRecord::Migration
  def change
    add_column :orders, :deduction, :integer, default: 0
    add_column :users, :deductible_points, :integer, default: 0
    remove_reference :points , :order
  end
end

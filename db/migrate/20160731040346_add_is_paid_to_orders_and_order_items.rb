class AddIsPaidToOrdersAndOrderItems < ActiveRecord::Migration
  def change
    add_column :orders, :is_paid, :boolean, default: false
    add_column :order_items, :is_paid, :boolean, default: false
    add_column :order_items, :step, :integer, default: 0
    add_column :orders, :payment, :integer
    add_column :orders, :order_items_count, :integer, default: 0
  end
end

class AddOrderItemStateDefault < ActiveRecord::Migration
  def change
    change_column_default :order_items, :state, 0
  end
end

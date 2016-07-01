class AddVariationToOrderItem < ActiveRecord::Migration
  def change
    add_reference :order_items, :variation, index: true, foreign_key: true
  end
end

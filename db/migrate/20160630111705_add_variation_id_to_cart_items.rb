class AddVariationIdToCartItems < ActiveRecord::Migration
  def change
    add_reference :cart_items, :variation, index: true, foreign_key: true
  end
end

class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product

  def unique?
    # binding.pry
    !self.product_id.in?(self.order.order_items.pluck(:product_id))
  end

  def total
    self.price*self.quantity
  end
end

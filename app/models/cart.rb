class Cart < ActiveRecord::Base
  belongs_to :user
  has_many :cart_items, dependent: :destroy

  def total_benefit
    benefit = 0
    self.cart_items.map do |item|
      benefit += item.benefit*item.quantity
    end
    benefit
  end

  def total_revenue
    self.total_benefit + self.total
  end

  def total
    total = 0
    self.cart_items.map do |item|
      total += item.price*item.quantity
    end
    total
  end

  def to_order_items
    order_items_attributes = []
    self.cart_items.map do |i|
      attrs = {}
      [:quantity, :price, :name, :product_id].map do |attr|
        attrs[attr] = i.send(attr.to_s)
      end
      order_items_attributes << attrs
    end
    return order_items_attributes
  end
end

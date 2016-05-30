class Cart < ActiveRecord::Base
  belongs_to :user
  has_many :cart_items

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
end

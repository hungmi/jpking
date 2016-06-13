class CartItem < ActiveRecord::Base
  before_create :fork
  
  belongs_to :cart
  belongs_to :product

  validate :unique?, on: :create
  # 不知道為啥沒用

  def unique?
    # binding.pry
    !self.product_id.in?(self.cart.cart_items.pluck(:product_id))
  end

  def fork
    self.quantity = self.product.wholesale_amount
  end

  def total_benefit
    self.product.single_benefit * self.quantity
  end

  def price
    self.product.our_price
  end

  def total
    self.price*self.quantity
  end

end

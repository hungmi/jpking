class CartItem < ActiveRecord::Base
  before_create :fork

  belongs_to :cart
  belongs_to :product

  def fork
    self.name = self.product.name
    self.price = self.product.our_price
    self.quantity = 1
    self.item_code = self.product.item_code
  end

  def wholesale_amount
    if self.name.index("（") && self.name.index("）")
      x_pos = self.name.index("x")
      return self.name[x_pos+1..-1][/\d+/].to_i
    else
      1
    end
  end

  def benefit
    self.product.their_price*self.wholesale_amount - self.price
  end

end

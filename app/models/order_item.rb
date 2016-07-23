class OrderItem < ActiveRecord::Base
  enum state: { placed: 0, paid: 1, importing: 2, imported: 3, stocked: 4, packaged: 5, ready_to_deliver: 6, delivered: 7, cancel: 8, unavailable: 9, wait: 10 }

  belongs_to :order
  belongs_to :product
  belongs_to :variation

  def unique?
    # binding.pry
    !self.product_id.in?(self.order.order_items.pluck(:product_id))
  end

  def price
    if self.order.paid?
      self.ordered_price
    else
      self.product.our_price
    end
  end

  def total
    return (self.price || 1)*(self.quantity || 1)
  end

  def i18n_state_for_admin
    I18n.t("order_item_state.admin.#{self.state}")
  end
end

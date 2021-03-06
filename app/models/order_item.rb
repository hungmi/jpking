class OrderItem < ActiveRecord::Base
  # enum state: { placed: 0, paid: 1, importing: 2, imported: 3, stocked: 4, packaged: 5, ready_to_deliver: 6, delivered: 7, cancel: 8, unavailable: 9, wait: 10 }
  enum state: { placed: 0, unavailable: 1, refunded: 2, ordered: 3 }
  enum step: { importable: 0, importing: 1, imported: 2, stocked: 3, ready_to_deliver: 4, delivered: 5 }
  scope :wait_for_pay, -> { where(is_paid: false).ordered }
  scope :paid, -> { where(is_paid: true) }

  belongs_to :order
  belongs_to :product
  belongs_to :variation
  has_one :point, dependent: :destroy

  def importable!
    if self.is_paid? && self.placed?
      super
    end
  end

  def refundable?
    self.is_paid? && self.unavailable?
  end

  def refunded!
    if self.is_paid? && self.unavailable?
      @user = User.find(self.order.user_id)
      if @user.present?
        @new_points = self.create_point(value: self.total, user_id: @user.id)
        @user.deductible_points += @new_points.value
        @user.save
      end
      super
    end
  end

  def paid?
    return self.is_paid?
  end

  def paid!
    self.update_column(:is_paid, true)
    self.importable!
  end

  def ordered!
    super
    self.update_column(:ordered_price, self.product.our_price)
  end

  def unique?
    # binding.pry
    !self.product_id.in?(self.order.order_items.pluck(:product_id))
  end

  def price
    @order_item = OrderItem.includes(:product, :order).where(id: self.id).first
    if @order_item.ordered?
      @order_item.ordered_price
    else
      @order_item.product.our_price
    end
  end

  def total
    return (self.price || 1)*(self.quantity || 1)
  end

  def i18n_state
    I18n.t("order_state.#{self.now_state}")
  end

  def now_state
    if self.paid?
      return self.importable? ? "paid" : self.step
    else
      return self.state
    end
  end
end

class Order < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  enum state: { placed: 0, delivered: 1, cancel: 2 }
  enum payment: { credit: 0, atm: 1 }
  enum delivery: { black_cat: 0, face: 1, cvs_711: 2, cvs_family: 3 }

  before_create :generate_order_num

  include Tokenable
  include Payable

  attr_accessor :_merge

  belongs_to :user
  belongs_to :cart
  has_many :points, dependent: :destroy
  has_many :order_items, dependent: :destroy, counter_cache: true

  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true

  def pay!
    self.paid!
    self.order_items.map { |oi| oi.paid! }
  end

  def paid?
    return self.is_paid?
  end

  def paid!
    self.update_column(:is_paid, true)
  end

  def final_total
    return self.total - self.points.pluck(:value).sum
  end

  # def sum_all_oi_totals
  #   sum = 0
  #   self.order_items.map do |item|
  #     sum += item.total
  #   end
  #   sum
  # end

  def generate_order_num
    self.num = rand(99).to_s.rjust(2,"0") + Time.now.strftime('%m%d%H%M%S')
  end

  def i18n_state
    I18n.t("order_state.#{self.now_state}")
  end

  def now_state
    if self.placed?
      if self.paid?
        return "paid"
      elsif self.atm?
        return "atm"
      else
        return "placed"
      end
    else
      return self.state
    end
  end

  def order_time
    created_at.strftime("%F %H:%M")
  end

  def cancelable?
    self.placed?# || self.paid?
  end

  def to_order_items
    order_items_attributes = []
    self.order_items.map do |i|
      order_items_attributes << i.attributes
    end
    return order_items_attributes
  end
end

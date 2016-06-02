class Order < ActiveRecord::Base
  default_scope { order(created_at: :desc) }

  enum state: { placed: 0, paid: 1, jp_ordered: 2, stocked: 3, packaged: 4, ready_to_deliver: 5, delivered: 6, cancel: 7 }
  enum delivery: { black_cat: 0, face: 1, cvs_711: 2, cvs_family: 3 }

  before_create :generate_order_num

  include Tokenable

  attr_accessor :_merge

  belongs_to :user
  belongs_to :cart
  has_many :order_items, dependent: :destroy

  accepts_nested_attributes_for :order_items, reject_if: :all_blank, allow_destroy: true

  def total
    total = 0
    self.order_items.map do |item|
      total += item.price*item.quantity
    end
    total
  end

  def generate_order_num
    self.num = rand(99).to_s.rjust(2,"0") + Time.now.strftime('%m%d%H%M%S')
  end

  def i18n_state_for_user
    I18n.t("order_state.user.#{self.state}")
  end

  def i18n_state_for_admin
    I18n.t("order_state.admin.#{self.state}")
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

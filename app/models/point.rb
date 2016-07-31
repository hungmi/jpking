class Point < ActiveRecord::Base
  enum reason: { refund: 0, coupon: 1 }
  belongs_to :order_item
  belongs_to :order
  belongs_to :user
end

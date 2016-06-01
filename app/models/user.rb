class User < ActiveRecord::Base
  has_secure_password
  has_one :cart
  has_many :orders
end

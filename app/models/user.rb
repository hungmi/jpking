class User < ActiveRecord::Base
  enum role: { pp: 0, admin: 1 }

  has_secure_password
  has_one :cart
  has_many :orders
end

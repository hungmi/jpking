class Shop < ActiveRecord::Base
  has_many :categories
  has_many :products
end

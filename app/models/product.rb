class Product < ActiveRecord::Base
  belongs_to :category

  include Fetchable

  validates :item_code, uniqueness: true, allow_blank: true
end

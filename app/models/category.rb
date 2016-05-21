class Category < ActiveRecord::Base
  scope :parent_categories, -> { where("parent_id IS NULL") }
  scope :sub_categories, -> { where("parent_id IS NOT NULL") }

  belongs_to :shop
  belongs_to :parent, class_name: "Category"
  has_many :children, class_name: "Category", foreign_key: :parent_id
  has_many :products

  include Fetchable

  validates :jp_name, :zh_name, uniqueness: true, allow_blank: true
end

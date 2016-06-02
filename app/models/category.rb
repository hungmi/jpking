class Category < ActiveRecord::Base
  scope :parent_categories, -> { where("parent_id IS NULL") }
  scope :sub_categories, -> { where("parent_id IS NOT NULL") }

  belongs_to :shop
  belongs_to :parent, class_name: "Category"
  has_many :children, class_name: "Category", foreign_key: :parent_id
  has_many :products

  include Fetchable

  validates :jp_name, :zh_name, uniqueness: true, allow_blank: true

  # def has_products?
  #   Category.
  # end

  def name
    zh_name ? zh_name : jp_name    
  end

  def child_products
    # sons = Product.includes(:category, :attachments).where(categories: { parent_id: self.id }).alive.ready.references(:category, :attachments)
    # self.children.map do |c|
    #   sons += Product.includes(:category, :attachments).where(categories: { parent_id: c.id }).alive.ready.references(:category, :attachments)
    # end
    # sons
    Product.joins(:category).includes(:attachments).where(category_id: self.children.pluck(:id)).references(:attachments).alive
  end

  def self_and_child_products
    Product.joins(:category).includes(:attachments).where(category_id: self.children.pluck(:id) << self.id).references(:attachments).alive
  end
end

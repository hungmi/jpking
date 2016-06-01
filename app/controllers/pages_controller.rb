class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:cart]

  def home
    @categories = Category.parent_categories
    @hot_products = Product.all[0..6]
  end

  def guide
  end

  def cart
    @cart = Cart.includes(:cart_items, cart_items: [:product, {product: [:attachments]}]).where(user_id: current_user.id).first
    @last_product = @cart.cart_items.last.try(:product)
  end

  def register
    
  end
end

class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:cart]

  def home
    @categories = Category.parent_categories
    @hot_products = Product.all.limit(7)
  end

  def guide
  end

  def cart
    @cart = Cart.includes(:cart_items, cart_items: [:product, {product: [:category]}]).where(user_id: current_user.id).first
    @cart_items = @cart.cart_items.order(:id)
    @last_product = @cart.cart_items.last.try(:product)
  end

  def register
    
  end

  def fb_bot
  end

  def crawl_posts
    @bbb = FbBot.new
    @results = {}
    if params[:post][:url].present?
      @results[params[:post][:url]] = @bbb.get_order_from_post(params[:post][:url])
    end
    # binding.pry
    respond_to do |format|
      format.js
      format.json { render json: @results, status: :ok }
    end
  end
end

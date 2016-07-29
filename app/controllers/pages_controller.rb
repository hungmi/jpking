class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:cart]

  def home
    # @categories = Category.parent_categories
    # @hot_products = Product.all.limit(7)
    @products = Product.where.not(ranking:nil).order(ranking: :asc).page params[:page]
  end

  def guide
  end

  def cart
    @cart = Cart.includes(:cart_items, cart_items: [:variation, :product, {product: [:category]}]).where(user_id: current_user.id).first
    @cart_items = @cart.cart_items.order(:id).group_by(&:product_id)
    @last_product = @cart.cart_items.last.try(:product)
  end

  def register
    @user = User.new
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

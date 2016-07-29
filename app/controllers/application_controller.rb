class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :user_signed_in?, :current_user, :current_page, :sign_in_as
  before_action :generate_cart, :set_ransack, :get_settings, :store_last_page!

  def get_settings
    $currency = Setting.first.currency || 0.31
    $tax_factor = Setting.first.tax_factor || 1.08
    $benefit_factor = Setting.first.benefit_factor || 1.05
  end

  def set_ransack
    @q = Product.alive.ransack(params[:q])
    # binding.pry
  end

  def generate_cart
    current_user.create_cart if user_signed_in? && current_user.cart.nil?
  end

  def authenticate_user!
    unless user_signed_in?
      redirect_to login_path
    end
  end

  def authenticate_admin!
    unless authenticate_user!
      if current_user.admin?
        return true
      else
        redirect_to root_path
      end
    end
  end

  def current_user
    User.includes(:cart).find_by_id(session[:user])
  end

  def user_signed_in?
    session[:user].present? && User.find_by_id(session[:user]).present?
  end

  def current_page
    params[:page].to_i.zero? ? 1 : params[:page].to_i
  end

  def store_last_page!
    if request.get? && controller_name != "sessions"
      session[:my_previous_url] = request.referer
    end
    puts "上一頁是：#{session[:my_previous_url]}"
  end

  def sign_in_as(user)
    session[:user] = user.id
  end
end

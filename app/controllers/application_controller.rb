class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :user_signed_in?, :current_user, :current_page
  before_action :generate_cart, :set_ransack, :store_last_page!

  def store_last_page!
    session[:my_previous_url] = request.env["HTTP_REFERER"]
  end

  def set_ransack
    @q = Product.ransack(params[:q])
    # binding.pry
  end

  def generate_cart
    current_user.create_cart if user_signed_in? && current_user.cart.nil?
  end

  def authenticate_user!
    redirect_to login_path unless user_signed_in?
  end

  def authenticate_admin!
    redirect_to login_path unless (user_signed_in? && current_user.admin?)
  end

  def current_user
    User.includes(:cart).find_by_id(session[:user])
  end

  def user_signed_in?
    session[:user].present?
  end

  def current_page
    params[:page].to_i.zero? ? 1 : params[:page].to_i
  end
end

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :user_signed_in?, :current_user
  before_action :generate_cart

  def generate_cart
    current_user.create_cart if user_signed_in? && current_user.cart.nil?
  end

  def authenticate_user!
    redirect_to login_path unless user_signed_in?
  end

  def current_user
    User.includes(:cart).find_by_id(session[:user])
  end

  def user_signed_in?
    session[:user].present?
  end
end

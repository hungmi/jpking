class SessionsController < ApplicationController
  def new
    # session[:my_previous_url] = request.env["HTTP_REFERER"]
  end

  def create
    @user = User.find_by(name: params[:user][:username])
    # false => 密碼錯誤
    # nil => 找不到使用者
    # true => 密碼正確
    case @user.try(:authenticate, params[:user][:password])
    when nil
      flash[:notice] = "查無使用者"
      redirect_to login_path
    when false
      flash[:notice] = "密碼錯誤"
      redirect_to login_path
    else
      session[:user] = @user.id
      flash[:notice] = "歡迎回來"
      redirect_to session[:my_previous_url] || root_path
    end
  end

  def destroy
    session[:user] = nil
    flash[:notice] = "期待您下次光臨"
    redirect_to root_path
  end

  def row_count
    session[:rowCount] = params[:rowCount].to_i.between?(1,12) ? params[:rowCount].to_i : nil
    redirect_to :back
  end
end
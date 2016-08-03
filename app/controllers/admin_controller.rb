class AdminController < ApplicationController
  before_action :authenticate_admin!
  layout 'admin'

  def panel
  end

  def settings
    @setting = Setting.first
  end

  def update_settings
    @setting = Setting.first
    @setting.update(settings_params)
    redirect_to admin_settings_path
  end

  def add_to_etoile_cart
    @ee = EtoileOrderBot.new
    if @ee.lets_order!
      flash[:success] = "已全部加入海渡購物車 #{view_context.link_to '前往查看', 'http://etonet.etoile.co.jp/ec/app/cart/list?deviceType=pc&currentTime=2016-06-11+17%3A24%3A36.714&viewMode=newarrival', target: '_blank'}".html_safe
    else
      flash[:warning] = "目前沒有任何海渡商品準備採購，或是採購時出現錯誤。"
    end
    redirect_to admin_orders_path
  end

  def fb_bot ; end

  def post_to_orders
    @bbb = FbBot.new
    if params[:post][:type] == "1"
      @results = @bbb.get_single_post_orders(params[:post][:url])
    else
      @results = @bbb.get_orders_in_post_comments(params[:post][:url])
    end
    respond_to do |format|
      format.js
    end
  end

  private

  def settings_params
    params.require(:setting).permit(:currency, :tax_factor, :benefit_factor)
  end
  
end
class AdminController < ApplicationController
  before_action :authenticate_admin!

  def add_to_etoile_cart
    @ee = EtoileOrderBot.new
    @ee.lets_order!
    flash[:success] = "已全部加入海渡購物車 #{view_context.link_to '前往查看', 'http://etonet.etoile.co.jp/ec/app/cart/list?deviceType=pc&currentTime=2016-06-11+17%3A24%3A36.714&viewMode=newarrival'}"
    redirect_to admin_orders_path
  end
  
end
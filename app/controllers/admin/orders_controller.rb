class Admin::OrdersController < AdminController
  
  def index
    params[:scope] = (params[:scope].present? && OrderItem.respond_to?(params[:scope])) ? params[:scope] : "all"
    @orders = Order.includes(:order_items, order_items: [:product, product: [:links] ]).where(order_items: { state: OrderItem.states[params[:scope]] })
    @importable_count = OrderItem.paid.size
    @importing_count = OrderItem.importing.size
    @imported_count = OrderItem.imported.size
    #@order_items = OrderItem.includes(:order, :product, product: [:links]).send(params[:scope])
  end

  def importing
    @order_item = OrderItem.find(params[:order_item_id])
    if @order_item.present?
      @order_item.product.check_availability!
      @order_item = @order_item.reload
      if @order_item.paid?
        @order_item.importing!
        flash[:success] = "加入訂購行列。"
        redirect_to :back
      elsif @order_item.unavailable?
        flash[:warning] = "此品項缺貨中。"
        redirect_to :back
      end
    else
      flash[:warning] = "此訂單品項不存在。"
      redirect_to :back
    end
  end

  def imported
    @order_item = OrderItem.find(params[:order_item_id])
    if @order_item.present?
      @order_item.product.check_availability!
      @order_item = @order_item.reload
      if @order_item.importing?
        @order_item.imported!
        flash[:success] = "完成訂購。"
        redirect_to :back
      elsif @order_item.unavailable?
        flash[:warning] = "此品項缺貨中。"
        redirect_to :back
      end
    else
      flash[:warning] = "此訂單品項不存在。"
      redirect_to :back
    end
  end

  def unavailable
    @order_item = OrderItem.find(params[:order_item_id]) 
    if @order_item.present?
      @order_item.product.check_availability!
      @order_item = @order_item.reload
      if @order_item.unavailable?
        flash[:success] = "完成缺貨通知。"
        redirect_to :back
      elsif !@order_item.unavailable?
        flash[:info] = "此品項已補貨。"
        redirect_to :back
      end
    else
      flash[:warning] = "此訂單品項不存在。"
      redirect_to :back
    end
  end

end
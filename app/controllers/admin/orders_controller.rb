class Admin::OrdersController < AdminController
  before_action :set_view_mode, only: [:index]
  layout 'admin'
  
  def index
    params[:scope] = (params[:scope].present? && OrderItem.respond_to?(params[:scope])) ? params[:scope] : "importable"
    # session[:importable_order_item_view_mode] ||= "orders"
    # session[:importing_order_item_view_mode] ||= "shops"
    # session[:imported_order_item_view_mode] ||= "shops"
    @orders = Order.includes(:order_items, order_items: [:product, product: [:links] ]).where(order_items: { step: OrderItem.steps[params[:scope]], is_paid: true, state: OrderItem.states[:placed] })
    @etoile_order_items = OrderItem.includes(:product, product: [:shop]).where(products: { shop_id: 1 }).importing
    @products = Product.includes(:order_items).where(order_items: { step: OrderItem.steps[params[:scope]], is_paid: true, state: OrderItem.states[:placed] }).group_by(&:shop_id)
    OrderItem.steps.keys.each do |step|
      instance_variable_set("@#{step}_count", OrderItem.send(step).paid.placed.size)
    end
    #@order_items = OrderItem.includes(:order, :product, product: [:links]).send(params[:scope])
  end

  def importing
    @order_item = OrderItem.find(params[:order_item_id])
    if @order_item.present?
      # @order_item.product.check_availability!
      # @order_item = @order_item.reload
      if @order_item.paid?
        @order_item.importing!
        flash[:success] = "加入訂購行列。"
        redirect_to :back
      # elsif @order_item.unavailable?
      #   flash[:warning] = "此品項缺貨中。"
      #   redirect_to :back
      end
    else
      flash[:warning] = "此訂單品項不存在。"
      redirect_to :back
    end
  end

  def imported
    @order_item = OrderItem.find(params[:order_item_id])
    if @order_item.present?
      # @order_item.product.check_availability!
      # @order_item = @order_item.reload
      if @order_item.importing?
        @order_item.imported!
        flash[:success] = "完成訂購。"
        redirect_to :back
      # elsif @order_item.unavailable?
      #   flash[:warning] = "此品項缺貨中。"
      #   redirect_to :back
      end
    else
      flash[:warning] = "此訂單品項不存在。"
      redirect_to :back
    end
  end

  def unavailable
    @order_item = OrderItem.find(params[:order_item_id]) 
    if @order_item.present?
      @order_item.product.short! unless @order_item.product.short?
      # @order_item.product.check_availability!
      @order_item = @order_item.reload
      # @order_item.unavailable!
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

  private

  def set_view_mode
    session[:paid_items_view_mode] ||= params[:paid_items_view_mode] || "orders"
    session[:importing_items_view_mode] ||= params[:importing_items_view_mode] || "shops"
    session[:imported_items_view_mode] ||= params[:imported_items_view_mode] || "shops"
  end

end
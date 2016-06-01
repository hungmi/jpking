class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :cancel, :reorder]
  before_action :authenticate_user!

  # GET /orders
  # GET /orders.json
  def index
    @orders = current_user.orders.all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = current_user.orders.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    cart = current_user.cart
    @order = current_user.orders.new(total: cart.total, order_items_attributes: cart.to_order_items)
    # binding.pry
    # @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        cart.cart_items.destroy_all
        format.html { redirect_to order_path(id: @order.token), notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_params)
        format.html { redirect_to order_path(@order.token), notice: '訂單已修改。' }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html { redirect_to order_path(@order.token), notice: '訂單目前無法修改，請聯絡客服。' }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def cancel
    @order.cancel! if @order.cancelable?
    respond_to do |format|
      format.html { redirect_to orders_url, notice: '訂單已取消。' }
      format.json { head :no_content }
    end
  end

  def reorder
    @order.placed! if @order.cancel?
    respond_to do |format|
      format.html { redirect_to order_path(@order.token), notice: '請確認訂單內容。' }
      format.json { head :no_content }
    end
  end

  def merge
    total = 0
    # order_items_attributes = []
    @new_order = current_user.orders.create# if order_items_attributes.present?
    #params[:merge_orders].values.map do |k,v|
    # binding.pry
    params[:merge_orders].map do |token, value|
      if value[:_merge] == "1" && (order = Order.find_by_token(token))
        # binding.pry
        total += order.total
        order.order_items.update_all(order_id: @new_order.id)
        order.reload.destroy
      end
    end

    @new_order.order_items.map do |i|
      unless i.unique?
        dup_quqntities = 0
        survivor = @new_order.order_items.where(product_id: i.product_id).first
        @new_order.order_items.where(product_id: i.product_id).map do |dup_i|
          dup_quqntities += dup_i.quantity
        end
        survivor.update_column(:quantity, dup_quqntities)
        @new_order.order_items.where(product_id: i.product_id).where.not(id: survivor.id).destroy_all
      end
    end

    if @new_order.reload.order_items.present?
      #binding.pry
      @new_order.update_column(:total, total)
      redirect_to @new_order
    else
      @new_order.destroy
      redirect_to root_path
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.includes(:order_items, order_items: [:product, product: [:attachments] ] ).find_by_token(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:num, :token, :user_id, :state, :delivery, :total, order_items_attributes: [ :product_id, :price, :quantity, :name, :id ])
    end
end

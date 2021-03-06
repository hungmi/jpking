class OrderItemsController < ApplicationController
  before_action :set_order_item, only: [:show, :edit, :update, :destroy, :refund]

  # GET /order_items
  # GET /order_items.json
  def index
    @order_items = OrderItem.all
  end

  # GET /order_items/1
  # GET /order_items/1.json
  def show
  end

  # GET /order_items/new
  def new
    @order_item = OrderItem.new
  end

  # GET /order_items/1/edit
  def edit
  end

  # POST /order_items
  # POST /order_items.json
  def create
    @order_item = OrderItem.new(order_item_params)

    respond_to do |format|
      if @order_item.save
        format.html { redirect_to @order_item, notice: 'Order item was successfully created.' }
        format.json { render :show, status: :created, location: @order_item }
      else
        format.html { render :new }
        format.json { render json: @order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /order_items/1
  # PATCH/PUT /order_items/1.json
  def update
    respond_to do |format|
      if @order_item.update(order_item_params)
        @order = @order_item.order
        @order.update_total!
        # format.html { redirect_to order_path(@order_item.order.token), notice: '修改完成' }
        format.json { render json: { total: @order.total }, status: :ok }
      else
        format.html { redirect_to order_path(@order_item.order.token), notice: '此項目無法修改。' }
        format.json { render json: @order_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_items/1
  # DELETE /order_items/1.json
  def destroy
    @order = @order_item.order
    if @order.cancelable?
      name = @order_item.name
      @order_item.destroy
      @order.update_total!

      if @order.order_items.blank?
        @order.destroy
        respond_to do |format|
          format.html {
            flash[:success] = "訂單已刪除。"
            redirect_to orders_path
          }
          format.json { head :no_content }
        end
      else
        respond_to do |format|
          format.html {
            flash[:success] = "已刪除#{name}。"
            redirect_to order_path(@order.token)
          }
          format.json { head :no_content }
        end
      end
    else
      respond_to do |format|
        format.html {
          flash[:warning] = "很抱歉，已無法更改訂單。"
          redirect_to order_path(@order.token)
        }
        format.json { head :no_content }
      end
    end
  end

  def refund
    respond_to do |format|
      if @order_item.refundable?
        @order_item.refunded!
        format.html {
          flash[:success] = "退款NT$ #{@order_item.total}已轉為購物金，您可以直接拿來抵扣其他商品！"
          redirect_to order_path(@order_item.order.token)
        }
        format.json { head :no_content }
      else
        format.html {
          flash[:warning] = "退款失敗！請稍候再試，或是詢問板板，我們將盡快為您處理。"
          redirect_to order_path(@order_item.order.token)
        }
        format.json { head :no_content }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_item
      @order_item = OrderItem.includes(:order, :variation, :product).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_item_params
      params.require(:order_item).permit(:order_id, :cart_item_id, :quantity, :price, :state, :name)
    end
end

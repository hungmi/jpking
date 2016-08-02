class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy, :pay, :cancel, :reorder, :is_cancelable, :pay2go_cc_notify]
  before_action :is_cancelable, only: [:pay, :cancel]
  before_action :authenticate_user!, except: [:pay2go_cc_notify]
  protect_from_forgery except: :pay2go_cc_notify

  def pay2go_cc_notify
    respond = JSON.parse(params["JSONData"])
    if respond["Status"] == "SUCCESS"
      result = JSON.parse(respond["Result"])
      @order.make_payment!(result)
      if @order.paid?
        flash[:success] = "付款成功！您將會收到一封包含付款資訊的郵件，請至少保留三個月。"
      elsif result["PaymentType"] == "VACC"
        flash[:success] = "取號成功！以下是您的匯款資訊，請記得在期限前完成！"
      end
      #   # UserMailer.pay_rent_success_mail(@rent).deliver_later
      #   flash[:success] = "Thanks!"#I18n.t('flash.messages.rent_payment_success')
      #   redirect_to result_rent_path(@rent)
      # else
      #   #render text: I18n.t('flash.messages.rent_payment_fail')
      # end
      redirect_to order_path(@order.token)
    else
      case respond["Status"]
      when "TRA20004"
        flash[:danger] = "很抱歉，交易失敗，請稍候再試一次，或聯絡我們。"
      when "TRA10016"
        flash[:danger] = "很抱歉，卡片授權失敗，請確認您使用的是 VISA, MASTER, 或 JCB 卡。"
      else
        flash[:danger] = "很抱歉，交易失敗，請稍候再試一次，或聯絡我們。"
      end
      redirect_to order_path(@order.token , status: respond["Status"])
    end
  end

  # GET /orders
  # GET /orders.json
  def index
    # @orders = Order.includes(:order_items, :user, order_items: [:order, :product]).where(user_id: current_user.id).all
    @orders = Order.includes(:order_items, :user, order_items: [:order, :product]).where(user_id: current_user.id).all
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @payment_info = @order.payment_info
    @order_item_groups = @order.order_items.order(state: :desc, updated_at: :desc).group_by(&:product_id)
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
        format.html {
          flash[:success] = "感謝您的訂購，請確認品項無誤，再進行付款"
          redirect_to order_path(id: @order.token)
        }
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
      if @order.cancelable? && @order.update(order_params)
        format.html {
          flash[:success] = '訂單已修改。'
          redirect_to order_path(@order.token)
        }
        format.json { render :show, status: :ok, location: @order }
      else
        format.html {
          flash[:warning] = '訂單目前無法修改，請聯絡客服。'
          redirect_to order_path(@order.token)
        }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy
    respond_to do |format|
      format.html {
        flash[:success] = "訂單 ##{@order.num} 已刪除！"
        redirect_to orders_url
      }
      format.json { head :no_content }
    end
  end

  # def pay
  #   @order.order_items.map do |oi|
  #     oi.update_column(:ordered_price, oi.product.our_price)
  #   end
  #   @order.pay!
  #   respond_to do |format|
  #     format.html { redirect_to orders_url, notice: '付款成功。' }
  #     format.json { head :no_content }
  #   end
  # end

  def cancel
    @order.cancel!
    respond_to do |format|
      format.html {
        flash[:info] = "我們會暫停處理這筆訂單。"
        redirect_to orders_url
      }
      format.json { head :no_content }
    end
  end

  def reorder # 取消後的重新訂購
    @order.placed! if @order.cancel?
    respond_to do |format|
      format.html { 
        flash[:success] = '請重新確認訂單內容。'
        redirect_to order_path(@order.token)
      }
      format.json { head :no_content }
    end
  end

  def merge # 多張未付款的訂單合為一張新的
    # 先確認所有訂單都是未付款的
    # binding.pry
    order_tokens = params[:order_tokens].split(",")
    @orders = Order.where(token: order_tokens)
    if @orders.size <= 1
      flash[:warning] = "選擇的訂單過少，無法合併。"
      redirect_to orders_path and return
    end
    @orders.each do |order|
      unless order.placed?
        flash[:danger] = "訂單 ##{order.num} 已付款，無法合併。"
        redirect_to orders_path and return
      end
    end

    total = 0
    @new_order = current_user.orders.create# if order_items_attributes.present?

    @orders.each do |order|
      total += order.total
      order.order_items.update_all(order_id: @new_order.id)
      order.reload.destroy
    end

    # 若欲合併的訂單中有重複的品項，會合在一起計算數量
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
      flash[:success] = "這是您合併後的新訂單。"
      redirect_to order_path(@new_order.token)
    else
      @new_order.destroy
      redirect_to root_path
    end
  end

  private
    def is_cancelable
      unless @order.cancelable?
        respond_to do |format|
          format.html { redirect_to order_path(@order.token), notice: '此操作無法執行。' }
          format.json { head :no_content }
        end
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.includes(:order_items, order_items: [:order, :variation, :product ] ).find_by_token(params[:id])
      redirect_to :back unless @order.present?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      params.require(:order).permit(:num, :token, :user_id, :state, :delivery, :total, order_items_attributes: [ :product_id, :variation_id, :price, :quantity, :name, :id ])
    end
end

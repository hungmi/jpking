class CartItemsController < ApplicationController
  before_action :set_cart_item, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /cart_items
  # GET /cart_items.json
  def index
    @cart_items = CartItem.all
  end

  # GET /cart_items/1
  # GET /cart_items/1.json
  def show
  end

  # GET /cart_items/new
  def new
    @cart_item = CartItem.new
  end

  # GET /cart_items/1/edit
  def edit
  end

  # POST /cart_items
  # POST /cart_items.json
  def create
    @cart_item = current_user.cart.cart_items.new(cart_item_params)

    respond_to do |format|
      if @cart_item.unique?
        if @cart_item.save
          format.html { 
            flash[:success] = "成功加入發財車！"
            redirect_to cart_path
          }
          format.json { render :show, status: :created, location: @cart_item }
        else
          format.html {
            flash[:danger] = '加入購物車失敗'
            redirect_to :back
          }
          format.json { render json: @cart_item.errors, status: :unprocessable_entity }
        end
      else
        format.html {
          flash[:warning] = '已加入購物車'
          redirect_to cart_path
        }
      end
    end
  end

  # PATCH/PUT /cart_items/1
  # PATCH/PUT /cart_items/1.json
  def update
    respond_to do |format|
      if @cart_item.update(cart_item_params)
        @cart = @cart_item.cart
        # format.html {
        #   flash[:success] = "更新成功！"
        #   redirect_to cart_path
        # }
        format.json { render json: { total: @cart.total, total_revenue: @cart.total_revenue, total_benefit: @cart.total_benefit }, status: :ok }
      else
        format.html { render :edit }
        format.json { render json: @cart_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cart_items/1
  # DELETE /cart_items/1.json
  def destroy
    @cart_item.destroy
    respond_to do |format|
      format.html {
        flash[:success] = "#{@cart_item.product.name} 已從訂單中移除！"
        redirect_to cart_path
      }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cart_item
      @cart_item = CartItem.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cart_item_params
      params.require(:cart_item).permit(:name, :price, :quantity, :product_id, :variation_id, :item_code)
    end
end

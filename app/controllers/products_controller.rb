class ProductsController < ApplicationController
  before_action :set_product, only: [:edit, :update, :destroy]
  before_action :set_row_count, only: [:index]

  # GET /products
  # GET /products.json
  def index
    # @category = Category.find_by_id(params[:category_id])
    # if @category.present?
    #   @children = @category.children
    #   @products = Product.includes(:links, :category, :attachments).where(categories: {parent_id: params[:category_id]}) + @category.products.includes(:links, :attachments)
    # else
    #   @products = Product.all.includes(:links, :attachments).where("attachments_count > 0").limit(100)
    # end
    # @q = Product.ransack(params[:q])#.alive
    @products = @q.result(distinct: true)#.includes(:category)
    @total_page = (@products.size / 100.0).ceil
    # binding.pry
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = Product.includes(:category).find_by_item_code(params[:item_code]) || Product.includes(:category).find_by_id(params[:id])
    @images = @product.attachments.order(:id)
    @page_title = @product.name
  end

  # GET /products/new
  def new
    @product = Product.new
  end

  # GET /products/1/edit
  def edit
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:shop_id, :jp_name, :zh_name, :original_price, :wholesale_price, :stock, :item_code)
    end

    def set_row_count
      params[:rowCount] = params[:rowCount].to_i.between?(1,12) ? params[:rowCount].to_i : nil
    end
end

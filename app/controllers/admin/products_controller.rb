class Admin::ProductsController < AdminController
  
  def index
    @products = Product.ranking.order(ranking: :asc)#.page params[:page]
    @users = User.all
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end
end
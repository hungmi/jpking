module ProductsHelper
  def add_to_cart_btn(product)
    capture do
      link_to cart_items_path(cart_item: { product_id: product.id, quantity: 1 }), class: "btn add_to_cart", method: :post do
        concat content_tag :i, "", class:"glyphicon glyphicon-shopping-cart"
        concat " 加入發財車"
      end
    end
  end
end

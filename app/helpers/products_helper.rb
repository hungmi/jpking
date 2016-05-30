module ProductsHelper
  def add_to_cart_btn(product)
    link_to cart_items_path(cart_item: { product_id: product.id, quantity: 1 }), class: "btn add_to_cart", method: :post do
      content_tag :i, nil, class:"glyphicon glyphicon-shopping-cart"
      "加入發財車"
    end
  end
end

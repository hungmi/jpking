module ProductsHelper
  def breadcrumb(product)
    categories = link_to(product.category.jp_name, category_path(product.category.jp_name, anchor: product.item_code), class:"btn btn-link")
    child = product.category
    # parent = children.parent
    while parent = child.parent do
      categories = link_to(parent.jp_name, category_path(parent.jp_name, anchor: product.item_code), class:"btn btn-link") + ">" + categories
      child = parent
    end
    categories
  end
  def add_to_cart_btn(product)
    capture do
      link_to cart_items_path(cart_item: { product_id: product.id, quantity: 1 }), class: "btn add_to_cart", method: :post do
        concat content_tag :i, "", class:"glyphicon glyphicon-shopping-cart"
        concat " 加入發財車" unless params[:rowCount]
      end
    end
  end
end

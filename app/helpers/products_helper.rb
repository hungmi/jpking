module ProductsHelper
  def product_path(product)
    human_product_path(item_code: product.item_code, product_name: product.name)
  end
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
    if product.alive?
      if product.variations.size > 0
        choose_variation_btn(product)
      else
        capture do
          link_to cart_items_path(cart_item: { product_id: product.id, quantity: product.wholesale_amount }), class: "btn add_to_cart", method: :post do
            concat content_tag :i, "", class:"glyphicon glyphicon-shopping-cart"
            concat content_tag :span, "加入發財車", class:"add-to-cart-text"# unless session[:rowCount] && (controller_name == "categories" && action_name == "show")
          end
        end
      end
    else
      capture do
        link_to "#", class: "btn btn-disabled short", disabled: "disabled" do
          concat content_tag :i, "", class:"glyphicon glyphicon-remove"
          concat content_tag :span, "商品缺貨中", class:"add-to-cart-text"
        end
      end
    end
  end

  def choose_variation_btn(product)
    capture do
      link_to product, class: "btn choose_variation" do
        concat content_tag :i, "", class:"glyphicon glyphicon-shopping-cart"
        concat content_tag :span, "選擇款式", class:"add-to-cart-text"
      end
    end
  end

  def dead_or_alive_btn(product)
    if product.alive?
      render "products/add_to_cart_form", product: product
    else
      capture do
        link_to "#", class: "btn btn-disabled short", disabled: "disabled" do
          concat "商品缺貨中"
        end
      end
    end
  end

  def dead_or_alive(product)
    if product.alive?
      "有庫存"
    else
      "售完補貨中"
    end
  end
end

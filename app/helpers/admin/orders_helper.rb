module Admin::OrdersHelper
  def render_notification(text)
    if text.to_i > 0
      content_tag :span, text, class: "notification", style: (text.to_i == 1 ? "padding: 0px 12px;" : "")
    end
  end

  def render_order_item_next_state_btn(item)
    if item.imported?
      link_to "入庫", admin_imported_path(order_item_id: item.id), class: "btn btn-primary", style: "width: 33.33%;", method: :post
    elsif item.importing?
      link_to "完成採購", admin_imported_path(order_item_id: item.id), class: "btn btn-primary", style: "width: 33.33%;", method: :post
    elsif item.paid?
      link_to "採購", admin_importing_path(order_item_id: item.id), class: "btn btn-primary", style: "width: 33.33%;", method: :post
    end
  end
end
module Admin::OrdersHelper
  def render_notification(text)
    if text.to_i > 0
      content_tag :span, text, class: "notification", style: (text.to_i == 1 ? "padding: 0px 12px;" : "")
    end
  end

  def render_order_item_next_state_btn(item)
    if item.delivered?
      "已完成"
    else
      now_step_index = OrderItem.steps[item.step]
      link_to I18n.t("order_state.#{OrderItem.steps.keys[now_step_index + 1]}"), admin_next_step_path(order_item_id: item.id), class: "btn btn-primary", style: "width: 33.33%;", method: :post
    end
  end

  OrderItem.steps.keys.each do |this_state|
    define_method "is_#{this_state}?" do
      params[:scope] == this_state
    end
  end
end
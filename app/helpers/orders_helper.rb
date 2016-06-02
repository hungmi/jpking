module OrdersHelper
  def render_order_state_btns(order)
    if order.cancel?
      link_to "再訂購", reorder_order_path(order.token), class: "btn btn-warning"
    elsif order.placed?
      capture do
        concat link_to "付款", root_path(order.token), class: "btn btn-warning"
        concat " "
        concat link_to "取消", cancel_order_path(order.token), class: "btn btn-danger"
      end
    elsif order.paid?
      capture do
        concat link_to "申請退款", root_path(order.token), class: "btn btn-warning"
      end
    end
  end
end

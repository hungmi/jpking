module OrdersHelper
  def render_order_state_btns(order)
    if order.cancel?
      link_to "再訂購", reorder_order_path(order.token), class: "btn btn-pink-alt btn-easier", style: "width: 100%;"
    elsif order.placed? && order.payment.blank?
      capture do
        concat render "partials/pay_button", order: order
        # concat link_to "確定進貨", pay_order_path(order.token), class: "btn btn-warning btn-easier", style: "width: 100%;"
        concat link_to "暫時壓單", cancel_order_path(order.token), class: "btn btn-link"
        concat contact_us
      end
    elsif order.payment_info.present? && !order.paid?
      capture do
        concat link_to "請按我確認匯款狀態", check_pay_order_path(order.token), class: "btn btn-pink-alt btn-easier", style: "width: 100%;", data: { disable_with: "確認中..." }
        # concat render "partials/check_pay_button", order: order
      end
    elsif order.paid?
      capture do
        concat link_to "返回", orders_path, class: "btn btn-link"
        concat contact_us
      end
    end
  end
end

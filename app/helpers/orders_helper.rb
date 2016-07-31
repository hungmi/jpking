module OrdersHelper
  def render_order_state_btns(order)
    if order.cancel?
      link_to "再訂購", reorder_order_path(order.token), class: "btn btn-warning btn-easier", style: "width: 100%;"
    elsif order.paid?
      if order.atm?
        capture do
          concat "匯款資訊"
          concat link_to "申請退款", root_path(order.token), class: "btn btn-default"
        end
      elsif order.credit?
        capture do
          concat "刷卡資訊"
          concat link_to "申請退款", root_path(order.token), class: "btn btn-default"
        end
      end
    elsif order.atm?
      capture do
        "匯款資訊"
      end
    elsif order.placed? && order.payment.blank?
      capture do
        concat render "partials/pay_button", order: order
        # concat link_to "確定進貨", pay_order_path(order.token), class: "btn btn-warning btn-easier", style: "width: 100%;"
        concat link_to "暫時壓單", cancel_order_path(order.token), class: "btn btn-link"
      end
    end
  end
end

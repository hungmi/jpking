module OrdersHelper
  def render_order_state_btns(order)
    if order.cancel?
      link_to "再訂購", reorder_order_path(order.token), class: "btn btn-warning btn-easier", style: "width: 100%;"
    elsif order.placed?
      capture do
        concat link_to "確定進貨", pay_order_path(order.token), class: "btn btn-warning btn-easier", style: "width: 100%;"
        concat link_to "暫時壓單", cancel_order_path(order.token), class: "btn btn-link"
      end
    elsif order.paid?
      capture do
        concat link_to "申請退款", root_path(order.token), class: "btn btn-warning"
      end
    end
  end

  ["paid", "importing", "imported"].each do |this_state|
    define_method "is_#{this_state}?" do
      params[:scope] == this_state
    end
  end
end

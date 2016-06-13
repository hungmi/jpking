module Admin::OrdersHelper
  def render_notification(text)
    if text.to_i > 0
      content_tag :span, text, class: "notification", style: (text.to_i == 1 ? "padding: 0px 12px;" : "")
    end
  end
end
module ApplicationHelper
  def meta_title
    @page_title.present? ? "#{@page_title} | JPP8" : "JPP8 | 日貨批發第一站"
  end

  def notice_message
    if flash.any?
      flash.map do |type, message|
        content_tag :div, class:"alert alert-#{type} alert-dismissible", role:"alert" do
          button_tag class:"close", data: { dismiss: "alert" }, aria: { label: "Close" } do
            content_tag :span do
              "&times;"
            end
          end
          content_tag :strong, type.capitalize
          message
        end
      end[0]
    end
  end

  def contact_us
    capture do
      link_to "https://m.me/jpp888/", class: "btn btn-link btn-easier contact_us", target: "_blank" do
        concat content_tag :i, "", class: "glyphicon glyphicon-question-sign"
        concat " 詢問板板"
      end
    end
  end

end

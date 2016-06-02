module ApplicationHelper
  def meta_title
    @page_title.present? ? "#{@page_title} | JPP8" : "JPP8 | 日貨批發第一站"
  end
  def contact_us
    capture do
      link_to "https://m.me/jpp888/", class: "btn contact_us", target: "_blank" do
        concat content_tag :i, "", class: "glyphicon glyphicon-question-sign"
        concat " 聯絡板板"
      end
    end
  end
end

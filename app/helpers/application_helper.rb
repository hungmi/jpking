module ApplicationHelper
  def meta_title
    @page_title.present? ? "#{@page_title} | JPP8" : "JPP8 | 日貨批發第一站"
  end
  def contact_us
    capture do
      link_to "https://m.me/jpp888/", class: "btn btn-link contact_us", target: "_blank" do
        concat content_tag :i, "", class: "glyphicon glyphicon-question-sign"
        concat " 聯絡板板"
      end
    end
  end

  def first_page
    link_to "1", params.merge(page: 1, anchor: "current-page"), class: "btn btn-link btn-sm"
  end
  def pages_divider
    "..."
  end
  def pages(inner_window, final_page)
    start_page = (current_page - inner_window >= 1) ? (current_page - inner_window) : 1
    end_page = (current_page + inner_window <= final_page) ? (current_page + inner_window) : final_page

    capture do
      for i in start_page..end_page do
        if i == current_page
          concat link_to i, params.merge(page: i, anchor: "pagination"), class: "btn btn-link btn-disabled", id: "current-page"
        else
          concat link_to i, params.merge(page: i, anchor: "pagination"), class: "btn btn-link"
        end
      end
    end
  end
  def final_page(final_page)
    link_to final_page, params.merge(page: final_page, anchor: "pagination"), class: "btn btn-link btn-sm"
  end
  def last_page(option={}) # 上一頁
    last_page = current_page - 1
    link_to("<<", params.merge(page: last_page, anchor: "pagination"), class: "btn btn-default #{option[:class]}", id: "#{option[:id]}") if last_page > 0
  end
  # current_page 移到 application_controller#helper_method
  # def current_page
  #   params[:page].to_i.zero? ? 1 : params[:page].to_i
  # end
  def next_page(total_page, option={}) # 下一頁
    next_page = current_page + 1
    link_to(">>", params.merge(page: next_page, anchor: "pagination"), class: "btn btn-default #{option[:class]}", id: "#{option[:id]}") if next_page <= total_page
  end
  def pagination(options = { inner_window: 2 })
    inner_window = options[:inner_window]
    final_page = options[:final_page]
    capture do
      content_tag :div, id: "pagination" do
        concat last_page(class: "btn-easier", id: "last-page")
        unless current_page - inner_window < 2
          concat first_page
          concat pages_divider
        end
        concat pages inner_window, final_page
        unless current_page + inner_window > final_page - 1
          concat pages_divider
          concat final_page(final_page)
        end
        concat next_page(@total_page, class: "btn-easier", id: "next-page")
      end
    end
  end
end

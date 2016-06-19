class FbBot
  require 'capybara'
  require 'capybara/dsl'
  require 'capybara/poltergeist'
  include Capybara::DSL
  Capybara.run_server = false
  Capybara.current_driver = :poltergeist
  Capybara.app_host = "https://zh-tw.facebook.com/"
  # Headless.new.start

  def initialize#(user,pass)
    puts "登入中"
    # @html = `phantomjs /Users/hungmi/Workspace/jpking/app/assets/javascripts/hello.js&`
    visit('/')
    page.save_screenshot
    if page.has_selector?('input[name="email"]')
      fill_in("email", with: "gn01189424@gmail.com")
      fill_in("pass", with: "peter012")
      find("input#u_0_m").trigger('click')
      # save_screenshot
    else
      puts "已登入"
    end
    page.save_screenshot
  end

  def get_single_post_orders(url)
    visit("/#{url.gsub(Capybara.app_host,'')}")
    @html = Nokogiri::HTML.parse(page.html)
    i = 0
    @results = {}
    @orders = {}
    # 頁面：該則貼文的專屬連結
    # 例如：https://www.facebook.com/groups/880774278680822/permalink/1032736396817942/
    # 整則貼文的文字
    @product = find(".userContent").text
    @picture = @html.search(".mtm img").attr('src').text
    # 各回覆的專屬連結
    @html.search(".UFIComment.UFIRow[aria-label='留言'] .UFICommentContent").each do |a|
      customer = a.search(".UFICommentActorName").text
      customer_id = a.search(".UFICommentActorName").attr("data-hovercard").text[/[^id=]\d+/]
      # unless customer == "江佳蓉"
        puts "正在抓取 comment##{i} ..."
        # save_screenshot
        @orders[customer_id] = { name: customer, content: a.search(".UFICommentBody").inner_html }
        # @orders[customer_id] = { name: customer, content: r.search(".UFICommentBody").text }
        @results[0] = { picture: @picture, title: @product, orders: @orders }
        i = i + 1
      # end
    end
    # binding.pry
    return @results
  end

  def get_orders_in_post_comments(url)
    visit("/#{url.gsub(Capybara.app_host,'')}")
    @html = Nokogiri::HTML.parse(page.html)
    @results = {}
    # 頁面：該則貼文的專屬連結
    # 例如：https://www.facebook.com/groups/880774278680822/permalink/1032736396817942/
    # 整則貼文的文字
    # puts find(".userContent").text
    # 各回覆的專屬連結
    i = 0
    @html.search(".UFICommentContentBlock .uiLinkSubtle").each do |a|
      unless a.attr('title').present?
        relative_url = a.attr('href')
        visit(relative_url)
        puts "正在抓取 comment##{i} ..."
        # save_screenshot
        html = Nokogiri::HTML.parse(page.html)
        @comment = html.search(".UFIComment.UFIRow[aria-label='留言'] .UFICommentContent")[i]
        
        @author = @comment.search(".UFICommentActorName").text
        @author_id = @comment.search(".UFICommentActorName").attr("data-hovercard").text[/[^id=]\d+/]
        @comment_body = @comment.search(".UFICommentBody").inner_html
        @orders = {}
        if @comment.search(".mvs a img").present? # 有圖才抓！！
          @picture = @comment.search(".mvs a img").attr("src").text
          if html.search(".UFIReplyList .UFIComment.UFIRow[aria-label='回應'] .UFICommentContent").present?
            @replys = html.search(".UFIReplyList .UFIComment.UFIRow[aria-label='回應'] .UFICommentContent")
            @replys.each do |r|
              customer = r.search(".UFICommentActorName").text
              customer_id = r.search(".UFICommentActorName").attr("data-hovercard").text[/[^id=]\d+/]
              # unless customer_id == @author_id
                @orders[customer_id] = { name: customer, content: r.search(".UFICommentBody").text }
              # end
            end
          end
        else
          @picture = nil
        end
        @results[i] = { picture: @picture, title: @comment_body, orders: @orders }
        i = i + 1
      end
    end

    return @results
    # 回覆人
    # @html.search(".UFICommentContent").map do |r|
    #   puts r.search(".UFICommentActorName").text
    #   puts r.search(".UFICommentBody").text
    # end

    # 頁面：一張圖片的專屬連結
    # 圖片貼文網址中的圖片文字內容
    # @html.search(".hasCaption").text
  end  
  
end
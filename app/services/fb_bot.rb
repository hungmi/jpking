class FbBot
  require 'capybara'
  require 'capybara/dsl'
  require 'capybara-webkit'
  include Capybara::DSL
  Capybara.run_server = false
  Capybara.current_driver = :webkit
  Capybara.app_host = "https://www.facebook.com/"

  def initialize#(user,pass)
    puts "登入中"
    visit('/')
    if page.has_selector?('input[name="email"]')
      fill_in("email", with: "gn01189424@gmail.com")
      fill_in("pass", with: "peter012")
      find("input#u_0_m").click
      # save_screenshot
    else
      puts "已登入"
    end
    # save_and_open_screenshot
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
      unless customer == "江佳蓉" # 若回覆有編輯過，會出現一個連結的title是 '顯示編輯紀錄'，要忽略掉
        puts "正在抓取 comment##{i} ..."
        # save_screenshot
        @orders[customer] = a.search(".UFICommentBody").inner_html
        @results[0] = { picture: @picture, title: @product, orders: @orders }
        i = i + 1
      end
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
        @comment_body = @comment.search(".UFICommentBody").inner_html
        if @comment.search(".mvs a img").present?
          @picture = @comment.search(".mvs a img").attr("src").text
        end
        @orders = {}
        if html.search(".UFIReplyList .UFIComment.UFIRow[aria-label='回應'] .UFICommentContent").present?
          @replys = html.search(".UFIReplyList .UFIComment.UFIRow[aria-label='回應'] .UFICommentContent")
          @replys.each do |r|
            customer = r.search(".UFICommentActorName").text
            unless customer.include? @author
              @orders[customer] = r.search(".UFICommentBody").text
            end
          end
        end
        # binding.pry
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
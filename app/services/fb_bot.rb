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

  def get_order_from_post(url)
    visit("/#{url.gsub(Capybara.app_host,'')}")
    if page.has_selector?('a.UFICommentActorName')
      @html = Nokogiri::HTML.parse(page.html)
      @names = {}
      @html.search(".UFICommentContent").map do |comment|
        @names[comment.search(".UFICommentActorName").text] = comment.search(".UFICommentBody span").text
      end
      @names
    end
    #save_and_open_screenshot
  end

  def get_post(url)
    visit("/#{url.gsub(Capybara.app_host,'')}")
    @html = Nokogiri::HTML.parse(page.html)
    @results = {}
    # 頁面：該則貼文的專屬連結
    # 例如：https://www.facebook.com/groups/880774278680822/permalink/1032736396817942/
    # 整則貼文的文字
    # puts find(".userContent").text
    # 各回覆的專屬連結
    @html.search(".UFICommentContentBlock .uiLinkSubtle").each_with_index do |a,i|
      relative_url = a.attr('href')
      visit(relative_url)
      save_screenshot
      @html = Nokogiri::HTML.parse(page.html)
      @comment = @html.search(".UFIComment.UFIRow:nth-child(#{i+1})[aria-label='留言'] .UFICommentContent")
      @author = @comment.search(".UFICommentActorName").text
      @commnet_body = @comment.search(".UFICommentBody")
      @picture = @comment.search(".mvs a").attr("href")
      @replys = @html.search(".UFIReplyList:nth-child(#{i+1}) .UFIComment.UFIRow[aria-label='回應'] .UFICommentContent")
      @orders = {}
      @replys.each do |r|
        customer = r.search(".UFICommentActorName").text
        unless customer.include? @author
          @orders[r.search(".UFICommentActorName").text] = r.search(".UFICommentBody").text
        end
      end
      # binding.pry
      @results[@picture] = @orders
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
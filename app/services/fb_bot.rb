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
  
  
end
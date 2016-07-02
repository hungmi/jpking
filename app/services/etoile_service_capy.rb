class EtoileServiceCapy  
  require 'capybara'
  require 'capybara/dsl'
  require 'capybara/poltergeist'
  include Capybara::DSL
  Capybara.run_server = false
  Capybara.current_driver = :poltergeist
  Rails.logger.level = 1

  def initialize#(username, password)
    Capybara.app_host = "http://etonet.etoile.co.jp"
    page.driver.headers = { "User-Agent": user_agent }
  end

  def fetch_rankings(base_url = ranking_page_url)
    # binding.pry
    signin!
    visit base_url
    # 先看一下總共有幾個
    # @html = Nokogiri::HTML.parse(page.html)
    # @ranking_html = Nokogiri::HTML.parse(page.html)
    # total_results = get_total_results(@ranking_html)
    # @category.update_column(:total, total_results)
    # @category = @category.reload
    # page_num = (total_results / 100.0).ceil
    Product.where.not(ranking: nil).update_all(ranking: nil)
    @ranking = 1
    for i in 1..10 do # 只抓前一千樣
      ranking_page_url = base_url.gsub("pageNo=1", "pageNo=#{i}")
      visit ranking_page_url
      fetch_products_on_this(page)
    end
    # binding.pry
    # for i in 2..page_num do
    #   @category.links.create(value: ranking_url.gsub(/pageNo=\d+/, "pageNo=#{i}") )
    # end
  end

  def fetch_products_on_this(ranking_page)
    # @category = Category.where(zh_name: "ranking").first_or_create
    parsed_html = Nokogiri::HTML.parse ranking_page.html
    parsed_html.search(".item_box").map do |item|
      # 取得商品資料
      
      product_ranking      = item.css("p.item_rank").text.to_i.zero? ? @ranking : item.css("p.item_rank").text.to_i
      product_name_in_link = item.css(".item_name > a") # <a href='產品連結'>產品名稱</a>
      params               = extract_params product_name_in_link.attr("href").to_s
      original_price       = item.search(".item_price1 p.price_num_small").first.text.gsub(",","")[/\d+/]
      wholesale_price      = item.search(".item_price2 p.price_num_small").first.text.gsub(",","")[/\d+/]
      wholesale_amount     = get_wholesale_amount(product_name_in_link.text)
      special_price        = item.search(".item_price3_small").first.text.gsub(",","")[/\d+/]
      ############################################################

      # 儲存商品及其連結，根據 item_code 找商品，如果有找到的話就會對應更新價格
      
      @product                  = Product.where( item_code: params[:productCode] ).first_or_create
      @product.jp_name          = product_name_in_link.text.strip
      @product.ranking          = product_ranking
      @product.original_price   = original_price
      @product.wholesale_price  = special_price || wholesale_price
      @product.wholesale_amount = wholesale_amount
      @product.save if @product.changed?
      ############################################################
      # binding.pry
      @product.strip_price_from_name!
      @product.links.create( value: Capybara.app_host + good_strip(product_name_in_link.attr("href").to_s) )
      # binding.pry
      # unless @product.description.present? || (@product.attachments.size > 0)
        fetch_product(@product.reload)
        # 正準備要抓各尺寸
      # end
      @ranking += 1
    end
  end

  def fetch_product(product)
    # 此方法是用來抓產品詳細資訊跟尺寸、顏色；大圖不一定要從這邊抓，因為大圖連結可以推斷出來
    # add state to product first, 可購買、已下架
    # 跑到各個目錄的 product list 比對列出的產品連結，這樣 request 最少
    # 也要寫 renew_categories

    # 不必登入也可以拿到清楚的圖
    # @agent = Mechanize.new
    # sign_in(@agent)
    target_link = product.links.alive.last
    
    unless target_link.up_to_date?
      puts "抓取 #{product.name} 中"
      @product_page = Nokogiri::HTML open(target_link.value)
      # binding.pry
      if @product_page.search("p.err_big").present?
        target_link.dead! && target_link.fetchable.dead!
      else
        { 'サイズ' => :product_size, '素材・原材料名・成分' => :material, 'コメント' => :description, '原産国' => :origin }.map do |k,v|
          find_detail_in_table(k, v, product)
        end
        # 抓它的目錄
        if product.category_id.blank?
          if (category_title = @product_page.search("li:contains('アイテム')").first).present?
            # binding.pry
            category_name = if category_title.parent.search("li").size >= 3
              category_title.parent.search("li:nth-child(3)").text.gsub(">","").squish.strip
            else
              category_title.parent.search("li:nth-child(2)").text.gsub(">","").squish.strip
            end
            category = Category.where(jp_name: category_name).first_or_create
            product.update(category_id: category.id)
            # binding.pry
          end
        end
        # 如果有尺寸或顏色的話，group_box 裡面會有一些 group_item_name
        if @product_page.search(".group_box > .group_item_name").present?
          variations = @product_page.search(".group_box > .group_item_name")
          
          variations.each do |v|
            if (variation_title = v.next_element.search("th:contains('品番')").first).present?
              item_code = variation_title.next_element.text.squish
            end
            if (gtin_code_title = v.next_element.search("th:contains('GTINコード')").first).present?
              gtin_code = gtin_code_title.next_element.text.squish
            end
            unless product.variations.where(item_code: item_code).present?
              product.variations.create(jp_name: v.text.strip, item_code: item_code, gtin_code: gtin_code)
            end
          end
          # binding.pry
        end
        images = @product_page.css("img[id*=image_]")
        images.each do |img|
          # binding.pry
          @attachment = product.attachments.new
          image_url = Capybara.app_host + img.attr("src").to_s.gsub("productnl","product").gsub("03_","01_")
          @attachment.source_url = image_url
          @attachment.description = img.attr("alt").to_s
          if @attachment.valid?
            @attachment.remote_image_url = image_url
            @attachment.save
          end
        end
        target_link.touch(:fetch_time)
      end
      sleep rand(5)
    end
  end
  
  private

    def find_detail_in_table(detail_title, attr_name, product)
      td_title = @product_page.search("table.detail_table th[text()*=#{detail_title}]").first
      if td_title.present?
        attr_value = td_title.parent.css("td").inner_html
        product.update_column(attr_name, attr_value)
      end   
    end

    def ranking_page_url
      "http://etonet.etoile.co.jp/ec/app/catalogue/list?priceRangeType=02&viewMode=ranking&iconViewMode=1&pageNo=1&dataCount=100&listImageSize=05&allClear=true&offset=-1&filterByOrderHistory=false&filterByMetadata=false&onlyDiscounted=false&onlyEtoileOriginal=false&onlyMadeInJapan=false&customerLimited=false&isProductAndCategoryNameSearch=false&rankingRangeType=0002&offsetSearch=false"
    end

    def user_agent
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36"
    end

    def signin!
      visit('/ec/app/auth/login')
      fill_in('username', with: "799300")
      fill_in('password', with: "bj680709")
      find("input#loginbutton").click()
      puts "報告老大，登入成功。"
    end

    def extract_params(href)
      parameters = {}
      href[/[^\?]*$/].strip.split("&").each do |param_str|
        result = param_str.split("=");
        parameters[result[0].to_sym] = result[1];
      end
      return parameters
    end

    def get_total_results(html)
      how_many_results_text = html.css("h2.default_title").text.strip
      start_pos = how_many_results_text.index("/") + 1
      return how_many_results_text[start_pos..-1].gsub(",","").gsub("件","").strip.to_i
    end

    def get_wholesale_amount(name)
      if name.index("（") && name.index("）") && name.index("x")
        x_pos = name.index("x")
        return name[x_pos+1..-1][/\d+/].to_i
      else
        1
      end
    end

    def good_strip(href) # 解決直接 strip 網址時，會出現 tab 無法清掉的問題
      params_in_href = href[/[^\?]*$/].strip
      return href[/^[^\?]*/] + "?" + params_in_href
    end
end
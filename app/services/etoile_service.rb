class EtoileService
  def initialize
    @home_url = "http://etonet.etoile.co.jp/ec/app/catalogue/index"
    @request_url = "http://etonet.etoile.co.jp"
    @shop = Shop.where(zh_name:"海渡", jp_name:"エトワール").first_or_create
  end
  
  def fetch_categories
    @category_type = 1
    @home = Nokogiri::HTML open(@home_url)
    @home.css("ul.side_menu_child")[@category_type].css("li.side_menu_child_root").map do |parent|
      # 第一層目錄
      @parent = @shop.categories.where(jp_name: parent.css("div.side_title > a").text.strip, tipe: @category_type).first_or_create
      # 第二層目錄
      parent.css("li.side_menu_child2_child > a").map do |children|
        
        params = extract_params children.attr("href")
        @children = @parent.children.where(jp_name: children.text.strip, tipe: @category_type, code: params[:categoryCode]).first_or_create
        @children.links.create( value: @request_url + good_strip(children.attr("href")).gsub(/dataCount=\d+/,"dataCount=100") )
      end
    end
  end

  def fetch_product_list_pages(category)
    url = category.links.first.value
    @first_page = Nokogiri::HTML open(url)
    params = extract_params url
    # 取得此分類商品數量，用來計算會有幾個 index 分頁
    how_many_results_text = @first_page.css("h2.default_title").text.strip
    start_pos = how_many_results_text.index("/") + 1
    total_results = how_many_results_text[start_pos..-1].gsub(",","").gsub("件","").strip.to_i
    
    page_num = (total_results / params[:dataCount].to_f).ceil
    for i in 2..page_num do
      category.links.create(value: url.gsub(/pageNo=\d+/, "pageNo=#{i}") )
    end
    ############
  end

  def fetch_products_in_this_category(category)
    # loop 此目錄中各分頁的連結，一千樣就有 10 頁
    category.links.map do |link|
      @page = Nokogiri::HTML open(link.value)
      
      @page.css(".item_box").map do |item|
        # 取得商品資料
        # item.css(".item_thm img").each do |img|
        product_name_in_link = item.css(".item_name > a") # 產品名稱，包含連結到產品
        params = extract_params product_name_in_link.attr("href").to_s
        # original_price = item.css(".item_price1 > .price_num")
        ############
        # 儲存商品及其連結
        @product = category.products.where( item_code: params[:productCode], jp_name: product_name_in_link.text.strip ).first_or_create
        @product.links.create( value: @request_url + good_strip(product_name_in_link.attr("href").to_s) )
        ############
      end
      sleep rand(20)
    end
  end

  def renew_products
    # add state to product first, 可購買、已下架
    # 跑到各個目錄的 product list 比對列出的產品連結，這樣 request 最少
    # 也要寫 renew_categories
  end

  private

    def extract_params(href)
      parameters = {}
      href[/[^\?]*$/].strip.split("&").each do |param_str|
        result = param_str.split("=");
        parameters[result[0].to_sym] = result[1];
      end
      return parameters
    end

    def good_strip(href) # 解決直接 strip 網址時，會出現 tab 無法清掉的問題
      params_in_href = href[/[^\?]*$/].strip
      return href[/^[^\?]*/] + "?" + params_in_href
    end
end
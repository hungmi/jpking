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
    @agent = Mechanize.new
    sign_in(@agent)
    category.links.map do |link|
      @page = @agent.get(link.value)  
      # binding.pry
      @page.search(".item_box").map do |item|
        # 取得商品資料
        binding.pry
        product_name_in_link = item.css(".item_name > a") # 產品名稱，包含連結到產品
        params = extract_params product_name_in_link.attr("href").to_s
        original_price = item.search(".item_price1 p.price_num_small").first.text.gsub(",","")[/\d+/]
        wholesale_price = item.search(".item_price2 p.price_num_small").first.text.gsub(",","")[/\d+/]
        special_price = item.search(".item_price3_small").first.text.gsub(",","")[/\d+/]
        # item.css(".item_thm img").each do |img|
        # image_url_base = item.css(".item_thm > a > img").attr("src").to_s.gsub("productnl","product").gsub("05_","01_")#.gsub("01.jpg","img_num.jpg")
        ############
        # 儲存商品及其連結
        if category.products.where( item_code: params[:productCode] ).present?
          @product = category.products.where( item_code: params[:productCode] ).first
          @product.original_price = original_price
          @product.wholesale_price = special_price || wholesale_price
          @product.save if @product.changed?
        else
          @product = category.products.where( item_code: params[:productCode], jp_name: product_name_in_link.text.strip, original_price: original_price, wholesale_price: wholesale_price ).create
        end
        # binding.pry
        @product.links.create( value: @request_url + good_strip(product_name_in_link.attr("href").to_s) )
        ############
      end
      sleep rand(20)
    end
  end

  def fetch_product(product)
    # 此方法是用來抓產品詳細資訊跟尺寸、顏色；大圖不一定要從這邊抓，因為連結可以推斷出來
    # add state to product first, 可購買、已下架
    # 跑到各個目錄的 product list 比對列出的產品連結，這樣 request 最少
    # 也要寫 renew_categories

    # 不必登入也可以拿到清楚的圖
    # @agent = Mechanize.new
    # sign_in(@agent)

    @product_page = Nokogiri::HTML open(product.links.last.value)
    images = @product_page.css("img[id*=image_]")
    images.each do |img|
      # binding.pry
      @attachment = product.attachments.new
      image_url = @request_url + img.attr("src").to_s.gsub("productnl","product").gsub("03_","01_")
      @attachment.source_url = image_url
      @attachment.description = img.attr("alt").to_s
      if @attachment.valid?
        @attachment.remote_image_url = image_url
        @attachment.save
      end
      sleep rand(5)
    end
  end

  def fetch_product_images_of_category(category)
    category.products.map do |p| # 注意此目錄底下必須有商品
      fetch_product(p)
      sleep rand(25)
    end
  end

  def fetch_rand_products(num)
    @processed_products = []
    # max = Product.all.size
    for i in 1..num
      p "start"
      target_product = Product.where("attachments_count = 0")[rand(Product.where("attachments_count = 0").size)]
      fetch_product(target_product)
      @processed_products << target_product.item_code
      p "pause"
      sleep rand(20)
    end
    p @processed_products
    # for i in 1..max do
    #   # binding.pry
    #   product = Product.all[rand(Product.all.size+1)]
    #   @processed_products << product.item_code
    #   fetch_product(product)
    #   sleep rand(20)
    #   i += 1
    # end
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

    def sign_in(agent)
      sign_in_page = agent.get("http://etonet.etoile.co.jp/ec/app/auth/login")
      sign_in_form = sign_in_page.form_with(name:"loginform")
      sign_in_form.username = "799300"
      sign_in_form.password = "bj680709"
      sign_in_form.submit
    end
end
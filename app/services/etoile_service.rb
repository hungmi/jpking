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
    category.update_column(:total, total_results)
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
    puts "已登入"
    category.links.map do |link|
      puts "正在抓取 #{category.name} 底下產品，目前進度 #{category.products.size} / #{category.total}"
      @page = @agent.get(link.value)
      # binding.pry
      @page.search(".item_box").map do |item|
        # 取得商品資料
        product_name_in_link = item.css(".item_name > a") # <a href='產品連結'>產品名稱</a>
        params = extract_params product_name_in_link.attr("href").to_s
        original_price = item.search(".item_price1 p.price_num_small").first.text.gsub(",","")[/\d+/]
        wholesale_price = item.search(".item_price2 p.price_num_small").first.text.gsub(",","")[/\d+/]
        wholesale_amount = get_wholesale_amount(product_name_in_link.text)
        special_price = item.search(".item_price3_small").first.text.gsub(",","")[/\d+/]
        ############
        # 儲存商品及其連結，根據 item_code 找商品，如果有找到的話就會對應更新價格
        if category.products.where( item_code: params[:productCode] ).present?
          @product = category.products.where( item_code: params[:productCode] ).first
          @product.original_price = original_price
          @product.wholesale_price = special_price || wholesale_price
          @product.save if @product.changed?
        else
          @product = category.products.where( item_code: params[:productCode], jp_name: product_name_in_link.text.strip, original_price: original_price, wholesale_price: wholesale_price, wholesale_amount: wholesale_amount ).first_or_create
        end
        # binding.pry
        @product.strip_price_from_name!
        @product.links.create( value: @request_url + good_strip(product_name_in_link.attr("href").to_s) )
        # sleep rand(10)
        fetch_product(@product)
        ############
      end
      sleep rand(5)
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
      puts "抓取 #{target_link.value} 中"
      @product_page = Nokogiri::HTML open(target_link.value)
      # binding.pry
      if @product_page.search("p.err_big").present?
        target_link.dead! && target_link.fetchable.dead!
      else
        { 'サイズ' => :product_size, '素材・原材料名・成分' => :material, 'コメント' => :description, '原産国' => :origin }.map do |k,v|
          find_detail_in_table(k, v, product)
        end

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
        end
        target_link.touch(:fetch_time)
      end
      sleep rand(2)
    end
  end

  def fetch_rand_products(num)
    @processed_products = []
    # max = Product.all.size
    for i in 1..num
      p "start"
      target_product = Product.alive[rand(Product.alive.size)]
      fetch_product(target_product)
      @processed_products << target_product.item_code
      p "pause"
      sleep rand(20)
    end
    p @processed_products
  end

  def fetch_product_images_of_category(category)
    category.products.map do |p| # 注意此目錄底下必須有商品
      fetch_product(p)
      sleep rand(25)
    end
  end

  ################################## 底下為暫時使用 #########################

  def fetch_product_info(product)
    @product_page = Nokogiri::HTML open(product.links.last.value)
    material_title = @product_page.search("table.detail_table th[text()*='素材・原材料名・成分']").first
    if material_title.present?
      material = material_title.parent.css("td").text
      product.update_column(:material, material)
    end

    product_title = @product_page.search("table.detail_table th[text()*='コメント']").first
    if product_title.present?
      description = product_title.parent.css("td").text
      product.update_column(:description, description)
    end
  end

  def fetch_rand_exist_products_info(num)
    @processed_products = []
    # max = Product.all.size
    num = Product.only_img.size
    for i in 1..num
      p "start"
      target_product = Product.only_img[i]
      fetch_product_info(target_product)
      @processed_products << target_product.item_code
      p "pause"
      sleep rand(10)
    end
    p @processed_products
  end

  ################################## 以上為暫時使用 #########################

  private

    def find_detail_in_table(detail_title, attr_name, product)
      td_title = @product_page.search("table.detail_table th[text()*=#{detail_title}]").first
      if td_title.present?
        attr_value = td_title.parent.css("td").inner_html
        product.update_column(attr_name, attr_value)
      end   
    end

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

    def get_wholesale_amount(name)
      if name.index("（") && name.index("）") && name.index("x")
        x_pos = name.index("x")
        return name[x_pos+1..-1][/\d+/].to_i
      else
        1
      end
    end
end
class Product < ActiveRecord::Base
  # default_scope { order(:id) }
  scope :ready, -> { where("attachments_count > 0 and products.description IS NOT NULL").alive }
  scope :not_ready, -> { where.not("attachments_count > 0 and products.description IS NOT NULL").alive }
  scope :only_img, -> { where("attachments_count > 0 and description IS NULL") }
  scope :page, -> (current_page) { limit(Product.per_page).offset(Product.per_page*(current_page - 1)) }

  enum state: { alive: 0, dead: 1 }

  def self.per_page
    30
  end

  belongs_to :shop
  belongs_to :category
  has_many :order_items
  has_many :variations

  include Fetchable
  include Imageable

  validates :item_code, uniqueness: true, allow_blank: true

  def their_price
    original_price ? (original_price * $tax_factor * $currency ).round : "無"
  end

  def our_price
    wholesale_price ? (wholesale_price / wholesale_amount * $benefit_factor * $tax_factor * $currency).round : "無"
  end

  def single_benefit
    self.wholesale_amount*self.their_price - self.our_price
  end

  def get_wholesale_amount
    if self.name.index("（") && self.name.index("）") && self.name.index("x")
      x_pos = self.name.index("x")
      return self.name[x_pos+1..-1][/\d+/].to_i
    else
      1
    end
  end

  def strip_price_from_name!
    if self.jp_name[/（?￥\d*\s*x\s*\d*）?/]
      self.jp_name = self.jp_name.gsub(/（?￥\d*\s*x\s*\d*）?/,"").squish.strip
    elsif self.jp_name[/￥\d*/]
      self.jp_name = self.jp_name.gsub(/￥\d*/,"").squish.strip
    end
    if self.changed?
      self.price_in_name = true
      self.save
    end
  end

  def name
    zh_name.present? ? zh_name : jp_name    
  end

  def on_price_com(args = {})
    name = args[:name] || self.jp_name
    rate = args[:rate].to_f > 0 ? args[:rate].to_f : 1
    if name.present?
      name_uri_code = CGI.escape name.encode("Shift_JIS","UTF-8")
      url = "http://kakaku.com/search_results/#{name_uri_code}"
      @page = Nokogiri::HTML open(url)
      results, prices = [], []
      @page.css("div.itemInfo").map do |p|
        prices << (p.css(".itemDbox .price .yen").text.delete(",")[/\d+/].to_i*rate).ceil
        binding.pry
        results << { name: p.css("p.itemnameN").text, price: prices.last, link: p.css("div.iviewbtn > a").attr("href").text }
        # TODO 商品圖片
      end
      { name: name, cheapest: { price: prices.min, link: results[prices.index(prices.min)] }, results: results }
    end
  end

  # def on_amazon(args = {})
  #   name = args[:name] || self.jp_name
  #   rate = args[:rate].to_f > 0 ? args[:rate].to_f : 1
  #   results = {}
  #   if name.present?
  #     url = "https://www.amazon.co.jp/s/ref=nb_sb_noss?field-keywords=#{name}"
  #     @page = Nokogiri::HTML open(url)
  #     imgs = @amazon.search(".s-result-item img").map do |img_html|
  #       img_html.attr("src")
  #     end
  #     names = @amazon.search(".s-access-detail-page h2").map do |name_link_html|
  #       name_link_html
  #     end
  #   end
  #   results[name] = { imgs: imgs, }
  # end

  def self.search(params)
    @products = Product.find_by_sql("SELECT * FROM products WHERE jp_name || zh_name || item_code || description ~* '.*#{params}.*'")
    params = params.gsub(" ","|")
    @or_products = Product.ready.alive.find_by_sql("SELECT * FROM products WHERE jp_name || zh_name || item_code || description ~* '.*#{params}.*'")
    return (@products + @or_products).uniq
  end

  def check_availability!
    target_link = self.links.last
    page = Nokogiri::HTML open(target_link.value)
    if page.search("p.err_big").present?
      target_link.dead! && target_link.fetchable.dead!
      target_link.fetchable.order_items.where(state: [OrderItem.states[:paid], OrderItem.states[:importing]]).update_all(state: OrderItem.states[:unavailable])
      return false
    else
      target_link.touch && target_link.fetchable.touch
      return true
    end
  end
end

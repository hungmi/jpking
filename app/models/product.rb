class Product < ActiveRecord::Base
  default_scope { order(:id) }
  scope :ready, -> { where("attachments_count > 0 and products.description IS NOT NULL").alive }
  scope :not_ready, -> { where.not("attachments_count > 0 and products.description IS NOT NULL").alive }
  scope :only_img, -> { where("attachments_count > 0 and description IS NULL") }

  enum state: { alive: 0, dead: 1 }

  belongs_to :category
  has_many :attachments, -> { where(attachments: { imageable_type: "Product" }) }, foreign_key: "imageable_id"#, class_name: "Attachment"

  include Fetchable
  include Imageable
  # include PgSearch

  # pg_search_scope :search, :against => [:jp_name, :zh_name, :description, :material, :item_code]

  validates :item_code, uniqueness: true, allow_blank: true

  def their_price
    original_price ? (original_price*1.08*1.05*0.3).round : "無"
  end

  def our_price
    wholesale_price ? (wholesale_price*1.08*1.05*0.3).round : "無"
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

  def self.search(params)
    @products = Product.includes(:attachments).ready.alive.references(:attachments).limit(100)
    params = params.gsub(" ","|")
    @or_products = Product.includes(:attachments).ready.alive.references(:attachments).limit(100)
    # binding.pry
    return (@products + @or_products).uniq
  end
end

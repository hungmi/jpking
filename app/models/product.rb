class Product < ActiveRecord::Base
  default_scope { order(id: :asc) }
  scope :ready, -> { where("attachments_count > 0 and products.description IS NOT NULL").alive }
  scope :not_ready, -> { where.not("attachments_count > 0 and products.description IS NOT NULL").alive }
  scope :only_img, -> { where("attachments_count > 0 and description IS NULL") }

  enum state: { alive: 0, dead: 1 }

  belongs_to :category

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

  def on_price_com(name)
    name ||= self.jp_name
    name_uri_code = CGI.escape name.encode("Shift_JIS","UTF-8")
    url = "http://kakaku.com/search_results/#{name_uri_code}"
    @page = Nokogiri::HTML open(url)
    @results = {}
    @page.css("div.itemInfo").map do |p|
      @results[p.css("p.itemnameN").text] = p.css(".itemDbox .price .yen").text.delete(",")[/\d+/]
      # TODO 商品圖片
    end
    @results
  end

  def self.search(params)
    params = params.gsub(" ","|")
    ready.alive.find_by_sql("SELECT * FROM products WHERE jp_name || zh_name || item_code || description ~* '.*#{params}.*'")
    # binding.pry
  end
end

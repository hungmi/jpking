class Product < ActiveRecord::Base
  belongs_to :category

  include Fetchable

  validates :item_code, uniqueness: true, allow_blank: true

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
end

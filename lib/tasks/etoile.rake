namespace :etoile do

  desc "找出還沒抓完的目錄繼續抓"
  task :crawl_new_products => :environment do
    @e = EtoileService.new
    Shop.find_by_zh_name("海渡").categories.map do |c|
      c.children.map do |cc|
        if cc.products.size != cc.total
          @e.fetch_products_in_this_category(cc)
        end
      end
    end
  end

end
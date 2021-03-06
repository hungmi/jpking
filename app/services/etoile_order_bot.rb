class EtoileOrderBot
  require 'capybara'
  require 'capybara/dsl'
  require 'capybara/poltergeist'
  include Capybara::DSL
  Capybara.run_server = false
  Capybara.current_driver = :poltergeist

  def initialize#(username, password)
    Capybara.app_host = "http://etonet.etoile.co.jp/"
    page.driver.headers = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36" }
    visit('/ec/app/auth/login')
    fill_in('username', with: "799300")
    fill_in('password', with: "bj680709")
    find("input#loginbutton").click()
    if page.has_selector?("div.item_price2")
      visit('/ec/app/cart/list?priceRangeType=02&viewMode=newarrival&iconViewMode=1&pageNo=1&dataCount=100&listImageSize=05&allClear=false&offset=-1&filterByOrderHistory=false&filterByMetadata=false&onlyDiscounted=false&onlyEtoileOriginal=false&onlyMadeInJapan=false&customerLimited=false&isProductAndCategoryNameSearch=false&rankingRangeType=0002&customerCode=799300&offsetSearch=false')
    end
    # print page.body
  end
  
  def lets_order!
    if OrderItem.importing.present?
      OrderItem.importing.map do |oi|
        fill_in('ruiban', with: oi.product.item_code[0..2])
        fill_in('hinban', with: oi.product.item_code[3..5])
        page.execute_script("searchProduct(getProductCode(), getProductVariationCode())")
        if page.has_selector?('#addCartButton')
          within("#directInputForm") { fill_in("purchaseQuantity", with: (oi.quantity/oi.product.wholesale_amount).to_s) }
          page.execute_script("$('#directInputForm').submit()")
        end
        oi.imported!
        puts "#{oi.name} 已訂購完成"
        return true
        # sleep rand(1)
      end
    else
      return false
    end
    # save_and_open_screenshot
  end
end
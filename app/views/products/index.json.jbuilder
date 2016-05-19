json.array!(@products) do |product|
  json.extract! product, :id, :shop_id, :jp_name, :zh_name, :original_price, :retail_price, :stock, :item_code
  json.url product_url(product, format: :json)
end

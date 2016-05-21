json.array!(@shops) do |shop|
  json.extract! shop, :id, :zh_name, :jp_name
  json.url shop_url(shop, format: :json)
end

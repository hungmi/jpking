json.array!(@orders) do |order|
  json.extract! order, :id, :code, :references, :state
  json.url order_url(order, format: :json)
end

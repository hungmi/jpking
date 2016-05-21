json.array!(@categories) do |category|
  json.extract! category, :id, :total, :jp_name, :zh_name, :code, :tipe
  json.url category_url(category, format: :json)
end

json.array!(@links) do |link|
  json.extract! link, :id, :value, :fetch_time, :state
  json.url link_url(link, format: :json)
end

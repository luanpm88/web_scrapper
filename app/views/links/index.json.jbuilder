json.array!(@links) do |link|
  json.extract! link, :id, :name, :source_url, :page_id, :category_id, :feature_id
  json.url link_url(link, format: :json)
end

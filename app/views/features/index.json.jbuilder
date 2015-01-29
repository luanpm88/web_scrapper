json.array!(@features) do |feature|
  json.extract! feature, :id, :name, :tag_list, :tag_item_title, :tag_item_link
  json.url feature_url(feature, format: :json)
end

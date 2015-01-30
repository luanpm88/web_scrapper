json.array!(@images) do |image|
  json.extract! image, :id, :name, :dir, :item_id, :source_url
  json.url image_url(image, format: :json)
end

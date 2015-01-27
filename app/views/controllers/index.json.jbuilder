json.array!(@controllers) do |controller|
  json.extract! controller, :id, :items
  json.url controller_url(controller, format: :json)
end

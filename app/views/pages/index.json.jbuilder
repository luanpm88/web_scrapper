json.array!(@pages) do |page|
  json.extract! page, :id, :name, :description
  json.url page_url(page, format: :json)
end

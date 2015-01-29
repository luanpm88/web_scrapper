class Item < ActiveRecord::Base
  validates :link, uniqueness: true
  
  belongs_to :page_link, :foreign_key => "link_id", :class_name => "Link"
  belongs_to :page
  belongs_to :category
  belongs_to :task
  
  def self.datatable(params)
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "items.name"
      when "2"
        order = "pages.name"
      when "3"
        order = "categories.name"
      else
        order = "items.name"
      end
      order += " "+params["order"]["0"]["dir"]
    end
    
    where = {}    
    where[:category_id] = params["category_id"] if !params["category_id"].empty?
    where[:page_id] = params["page_id"] if !params["page_id"].empty?
    search_q = "LOWER(pages.name) LIKE '%#{params["search"]["value"].downcase}%' OR LOWER(categories.name) LIKE '%#{params["search"]["value"].downcase}%' OR LOWER(items.name) LIKE '%#{params["search"]["value"].downcase}%'" if !params["search"]["value"].empty?
    
    total = self.joins(:category).joins(:page).count
    
    @items = self.joins(:category).joins(:page).where(where).where(search_q)
    @items = @items.order(order) if !order.nil?
    
    filtered = @items.count
    
    @items = @items.limit(params[:length]).offset(params[:start])
    
    data = []
    @items.each do |item|
      item = [
        item.name,
        item.page.name,
        item.category.name,
        '<a target="_blank" href="'+item.link+'">'+item.link+'</a>'
      ]
      data << item
    end 
    
    result = {
              "drawn" => params[:drawn],
              "recordsTotal" => total,
              "recordsFiltered" => filtered
    }
    result["data"] = data
    
    return result
  end
end

class Item < ActiveRecord::Base
  validates :link, uniqueness: true
  
  belongs_to :page_link, :foreign_key => "link_id", :class_name => "Link"
  belongs_to :page
  belongs_to :category
  belongs_to :task
  
  has_many :images
  
  def self.datatable(params)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
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
      
            
      
      actions = '
        <div class="btn-group">
          <button type="button" class="btn btn-sm btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
            Actions <span class="caret"></span>
          </button>
          <ul class="dropdown-menu" role="menu">
            <li>'+link_helper.link_to('Scrap Details', {controller: "items", action: "scrap_details", id: item.id})+'</li>
            <li>'+link_helper.link_to('Edit', {controller: "items", action: "edit", id: item.id})+'</li>
            <li>'+link_helper.link_to('Destroy', {controller: "items", id: item.id},"data-confirm" => "Are you sure?", "data-method" => "delete")+'</li>          
          </ul>
        </div>
      '
      
      item = [        
        item.name,
        item.page.name,
        item.category.name,
        '<div class="text-center">'+item.images.count.to_s+'</div>',
        '<a target="_blank" href="'+item.link+'">'+item.link+'</a>',
        actions
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
  
  def scrap_details
    details = Task.render_item(self)
    images = details[:images]
    
    valid = true
    
    #save image
    if images.count > 0
      images.each_with_index do |image,index|
        if image.download_image(index.to_s)
          if !image.save
            valid = false
          end
        end
      end
    else
      valid = false
    end
    
    if valid
      self.update_attribute('details_updated', 1)
    end
    
    
    return valid
  end
end

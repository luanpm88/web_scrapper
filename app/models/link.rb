class Link < ActiveRecord::Base
  validates :name, :presence => true
  validates :feature_id, :presence => true
  validates :source_url, :presence => true
  validates :page_id, :presence => true
  validates :category_id, :presence => true
  
  validate :link_must_be_valid
  
  belongs_to :page
  belongs_to :category
  belongs_to :feature
  
  has_many :items
  
  def enable
    if self.is_valid
      self.update_attribute('status', 1)
      return true
    else
      self.update_attribute('status', -1)
      return false
    end
  end
  
  def disable
    self.update_attribute('status', 0)
  end
  
  def invalid
    self.status = -1
    self.save
  end
  
  def link_must_be_valid
    msg = "Link can not be scrap! Try another settings."
        
    if !self.is_valid
      errors.add(:base, msg)
    end
  end
  
  def is_valid
    if self.feature_id.nil?
      return false
    end
    
    if self.source_url.empty?
      return false
    end
    
    log = Task.test_link(self)[:log]    
    result = Task.is_valid_link(log)
    
    if !result
      return false
    end
    
    return true
  end
  
  
    
  def self.datatable(params)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "links.source_url"
      when "2"
        order = "pages.name"
      when "3"
        order = "categories.name"
      else
        order = "features.name"
      end
      order += " "+params["order"]["0"]["dir"]
    end
    
    where = {}    
    where[:category_id] = params["category_id"] if !params["category_id"].empty?
    where[:page_id] = params["page_id"] if !params["page_id"].empty?
    search_q = "LOWER(pages.name) LIKE '%#{params["search"]["value"].downcase}%' OR LOWER(categories.name) LIKE '%#{params["search"]["value"].downcase}%' OR LOWER(links.name) LIKE '%#{params["search"]["value"].downcase}%'" if !params["search"]["value"].empty?
    
    
    total = self.joins(:category).joins(:page).joins(:feature).count
    @items = self.joins(:category).joins(:page).joins(:feature).where(where).where(search_q)
    @items = @items.order(order) if !order.nil?
    
    filtered = @items.count
    
    @items = @items.limit(params[:length]).offset(params[:start])
    
    data = []
    @items.each do |item|      
      
      if item.status == 1
        auto_cron = link_helper.link_to('On', {controller: "links", action: "disable", id: item.id}, :class => "btn btn-sm btn-success")      
      else
        auto_cron = link_helper.link_to('Off', {controller: "links", action: "enable", id: item.id}, :class => "btn btn-sm btn-default")
      end
      
      actions = '
        <div class="btn-group">
                      <button type="button" class="btn btn-sm btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                        Actions <span class="caret"></span>
                      </button>
                      <ul class="dropdown-menu" role="menu">
                        <li>'+link_helper.link_to('Test', {controller: "links", action: "test_link", id: item.id})+'</li>
                        <li>'+link_helper.link_to('Edit', {controller: "links", action: "edit", id: item.id})+'</li>
                        <li>'+link_helper.link_to('Destroy', {controller: "links", id: item.id},"data-confirm" => "Are you sure?", "data-method" => "delete")+'</li>          
                      </ul>
                    </div>
      '
      
      node = [
        '<div class="">'+link_helper.link_to(item.name, item.source_url, :target => "_blank")+'</div>',
        item.page.name,
        item.category.name,
        item.feature.name,        
        '<div class="text-center">'+auto_cron+'</div>',
        '<div class="text-right">'+actions+'</div>'
      ]
      data << node
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

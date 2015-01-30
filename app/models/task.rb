class Task < ActiveRecord::Base
  belongs_to :page
  belongs_to :category
  belongs_to :link
  
  has_many :items
  has_many :task_logs
  
  validates :page_id, :presence => true
  validates :category_id, :presence => true
  
  def is_running
    if !self.finished_at.nil? && !self.started_at.nil?
      return self.finished_at < self.started_at
    else
      return false
    end   
  end
  
  def links
    Link.where(:page_id => self.page_id, :category_id => self.category_id)
  end
  
  def run
    system("ruby scrapper.rb #{self.id} >> scrapper.log 2>&1 &")
  end
  
  def self.render_item(item)
    feature = item.page_link.feature
    
    m = Mechanize.new
    begin
      page = m.get(item.link)
    rescue Exception => e
      puts e.message
      return {images: []}
    end
    content = page.search('body').text
    
    #search images
    images = []
    if feature.innerpage_image_regex.present?
      image_urls = content.scan(/#{feature.innerpage_image_regex}/)
      image_urls = image_urls.uniq      
      
      if image_urls.count > 0
        image_urls.each do |url|
          if !url.empty? 
            image = item.images.new(source_url: url.first)
            images << image
          end
        end
      else
        puts "Can't find images"
      end
    end
    
    return {images: images}
      
  end
  
  
  
  def scrap_links
    self.update_attribute('started_at', DateTime.now)
    
    self.links.where(status: 1).each do |link|
      scrap_link(link.id)
    end
    
    #scrap item details
    self.links.where(status: 1).each do |link|
      link.scrap_items
    end
    
    self.update_attribute('finished_at', DateTime.now)
  end
 
  def scrap_link(link_id)
    # Find all links
    link = Link.find(link_id)
    
    result = Task.render_link(link)
    
    items = result[:items]
    log = result[:log]
    
    log.success = save_items(items, link)
    self.task_logs << log
    
    # disable link if not valid
    if !Task.is_valid_link(log)
      link.invalid
    end    
    
    return {items: items, log: log}
  end
  
  def self.test_link(link_id)
    result = render_link(link_id)
    
    items = result[:items]
    log = result[:log]
    
    log.success = test_items(items)
    
    return {items: items, log: log}
  end
  
  def save_items(items, link)
    success = 0
    items.each do |row|
      row.task_id = self.id
      row.link_id = link.id
      row.page_id = link.page_id
      row.category_id = link.category_id
          
      if row.save
        success += 1
      end
    end
    return success
  end
  
  def self.test_items(items)
    success = 0
    items.each do |row|
      if row.valid?
        success += 1
      end
    end
    return success
  end
  
  def self.is_valid_link(log)
    if log.total > 0 && log.error < log.total
      return true
    else
      return false
    end   
  end
  
  def self.render_link(link)
    # Find all links
    
    source_url = link.source_url
    tag_list = link.feature.tag_list
    tag_item_title = link.feature.tag_item_title
    tag_item_link = link.feature.tag_item_link
    
    m = Mechanize.new
    
    begin
      page = m.get(source_url)
    rescue  Exception => e
      return {items: [], log: TaskLog.new(total: 0, error: 0, error_message: e.message)}
    end
    
    list = page.search(tag_list)
    
    total = list.count
    error = 0
    success = 0
    
    items = []
    if list.count > 0
      list.each do |node|
        item = Item.new
        valid = true
        #get item name
        if !node.search(tag_item_title).first.nil?
          item.name = node.search(tag_item_title).first.text
        else
          puts 'Can\'t find item name!'
          valid = false
        end
        
        #get item link and full name
        if !node.search(tag_item_link).first.nil? 
          node.search(tag_item_link).first.attributes.map do |a,b|
            item.link = b if a=='href'
            item.name = b if a=='title'
          end
        else
          puts 'Can\'t find item link!'
          valid = false
        end
        
        if valid
          
          
          items << item
        else
          puts 'Can\'t find scrap item!'
          error += 1
        end
      end
      
      if items.count == 0
        puts 'Can\'t find any item!'
      end      
    else
      puts 'Can\'t find list!'
    end
    
    log = TaskLog.new(total: total, error: error)
    
    return {items: items, log: log}
  end
  
  def start
    self.status = 1
    self.save
    
    Task.render_crontab
  end
  
  def stop
    self.status = 0
    self.save
    
    Task.render_crontab
  end
  
  def self.render_crontab
    
    # Crontab
    crontab_read = "crontab -l"
    crontab_write = "crontab crontab.tmp"
    
    crontab_current = ""
    #check if have any crontab
    if `#{crontab_read}`.empty?
      `rm crontab.tmp`
      `touch crontab.tmp`
      `#{crontab_write}`
      
      puts "create new crontab!"
    end
    
    crontab_current = `#{crontab_read}`.strip
    
    puts crontab_current
    #remove old cron
    crontab_current = crontab_current.gsub(/\#BEGIN_WEB_SCRAPPER.*\#END_WEB_SCRAPPER/m,"")
    
    dir = File.expand_path(File.dirname(__FILE__)).gsub("/app/models","")+"/script"
    script_dir = File.expand_path(File.dirname(__FILE__)).gsub("/app/models","")+"/script/scrapper.rb"
    log_dir = File.expand_path(File.dirname(__FILE__)).gsub("/app/models","")+"/script/scrapper.log"
    
    cron = ""
    
    tasks = Task.where(status: 1)
    if !tasks.empty?
      cron += "#BEGIN_WEB_SCRAPPER\n"
      Task.where(status: 1).each do |task|
        cron += "* * * * * cd #{dir} && ruby scrapper.rb >> scrapper.log 2>&1\n"
      end
      cron += "#END_WEB_SCRAPPER"
    end
      
    
    #write cron
    File.open("crontab.tmp", 'w') do |f|
      f.puts crontab_current+cron
    end
    
    `#{crontab_write}`
  end
  
  def self.datatable(params)
    ActionView::Base.send(:include, Rails.application.routes.url_helpers)
    link_helper = ActionController::Base.helpers
    
    if !params["order"].nil?
      case params["order"]["0"]["column"]
      when "1"
        order = "tasks.name"
      when "2"
        order = "pages.name"
      when "3"
        order = "categories.name"
      else
        order = "tasks.name"
      end
      order += " "+params["order"]["0"]["dir"]
    end
    
    where = {}    
    where[:category_id] = params["category_id"] if !params["category_id"].empty?
    where[:page_id] = params["page_id"] if !params["page_id"].empty?
    search_q = "LOWER(pages.name) LIKE '%#{params["search"]["value"].downcase}%' OR LOWER(categories.name) LIKE '%#{params["search"]["value"].downcase}%' OR LOWER(tasks.name) LIKE '%#{params["search"]["value"].downcase}%'" if !params["search"]["value"].empty?
    
    total = self.joins(:category).joins(:page).count
    
    @items = self.joins(:category).joins(:page).where(where).where(search_q)
    @items = @items.order(order) if !order.nil?
    
    filtered = @items.count
    
    @items = @items.limit(params[:length]).offset(params[:start])
    
    data = []
    @items.each do |item|      
      
      if item.is_running     
        auto_cron = "Running..."
      elsif item.status == 1
        auto_cron = link_helper.link_to('On', {controller: "tasks", action: "stop", id: item.id}, :class => "btn btn-sm btn-success")      
      else
        auto_cron = link_helper.link_to('Off', {controller: "tasks", action: "start", id: item.id}, :class => "btn btn-sm btn-default")
      end
      
      if item.is_running     
        run_but = ''
      else
        run_but = '<li>'+link_helper.link_to('Run', {controller: "tasks", action: "run", id: item.id})+'</li>'
      end
      
      actions = '
        <div class="btn-group">
                      <button type="button" class="btn btn-sm btn-default dropdown-toggle" data-toggle="dropdown" aria-expanded="false">
                        Actions <span class="caret"></span>
                      </button>
                      <ul class="dropdown-menu" role="menu">
                      '+run_but+'
                        <li>'+link_helper.link_to('Edit', {controller: "tasks", action: "edit", id: item.id})+'</li>
                        <li>'+link_helper.link_to('Destroy', {controller: "tasks", id: item.id},"data-confirm" => "Are you sure?", "data-method" => "delete")+'</li>          
                      </ul>
                    </div>
      '
      
      node = [
        link_helper.link_to(item.name, {controller: "tasks", action: "show", id: item.id}),
        item.page.name,
        item.category.name,
        'Links: '+item.links.count.to_s+'<br />Items: '+item.items.count.to_s,
        '<div class="text-center">'+item.min+'  '+item.hour+'  '+item.day+'  '+item.month+'  '+item.week+'  '+'</div>',
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

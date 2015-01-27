require 'active_record'
require 'mechanize'
#require 'pg' # or 'pg' or 'sqlite3'

# Change the following to reflect your database settings
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3', # or 'postgresql' or 'sqlite3'
  database: '../db/development.sqlite3'
)

#Item class
require '../app/models/item.rb'

# Define your classes based on the database, as always
class Scrapper
  
  
  def initialize(url)
    @url = url
    
    @tag_list = "#s-results-list-atf li"
    @tag_item_title = "h2"
    @tag_item_link = "a.a-link-normal"
    
  end
  
  def scrap_list
    m = Mechanize.new
    page = m.get(@url)
    list = page.search(@tag_list)
    
    items = []
    if list.length
      list.each do |node|
        item = Item.new
        
        #get item name
        if !node.search(@tag_item_title).first.nil?
          item.name = node.search(@tag_item_title).first.text
        end
        
        #get item link
        if !node.search(@tag_item_link).first.nil? 
          node.search(@tag_item_link).first.attributes.map { |a,b| item.link = b if a=='href' }
        end
        
        #download and save image
        if !node.search(@tag_item_link).first.nil? 
          node.search(@tag_item_link).first.attributes.map { |a,b| item.link = b if a=='href' }
        end
        
        items << item
      end
    else
      puts 'Can\'t find anything!'
    end
    return items
  end
end

# Now do stuff with it
# scraper = Scrapper.new
# puts scraper.find :all


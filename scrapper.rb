require 'active_record'
require 'mechanize'
require 'open-uri'

DIR = File.expand_path(File.dirname(__FILE__))

# Change the following to reflect your database settings
ActiveRecord::Base.establish_connection(
  adapter:  'sqlite3', # or 'postgresql' or 'sqlite3'
  database: DIR+'/db/development.sqlite3'
)

#Item class
require DIR+'/app/models/category.rb'
require DIR+'/app/models/feature.rb'
require DIR+'/app/models/item.rb'
require DIR+'/app/models/link.rb'
require DIR+'/app/models/page.rb'
require DIR+'/app/models/task.rb'
require DIR+'/app/models/task_log.rb'
require DIR+'/app/models/image.rb'

task_id = ARGV.first

t = Task.find(task_id)

t.scrap_links









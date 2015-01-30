class Image < ActiveRecord::Base
  require 'open-uri'
  
  validates :filename, uniqueness: true
  
  belongs_to :item
  
  def download_image(index="")
    dir = "images"
    if !File.directory?(dir)
      `mkdir images`
    end
    dir += "/"
    
    image_name = 'image_'+self.item.id.to_s+"_"+index+File.extname(self.source_url).to_s
    puts image_name
    
    begin
      open(self.source_url) {|f|
        File.open(dir+image_name,"wb") do |file|
          file.puts f.read
        end
      }
      self.dir = dir
      self.filename = image_name
      
      return true
    rescue
      puts "Can't download image"
      return false
    end
  end
end

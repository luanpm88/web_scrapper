class AddInnerpageImageRegexToFeatures < ActiveRecord::Migration
  def change
    add_column :features, :innerpage_image_regex, :text
  end
end

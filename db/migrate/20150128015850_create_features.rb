class CreateFeatures < ActiveRecord::Migration
  def change
    create_table :features do |t|
      t.text :name
      t.text :tag_list
      t.text :tag_item_title
      t.text :tag_item_link

      t.timestamps null: false
    end
  end
end

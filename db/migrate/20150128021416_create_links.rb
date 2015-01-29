class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.text :name
      t.text :source_url
      t.integer :page_id
      t.integer :category_id
      t.integer :feature_id

      t.timestamps null: false
    end
  end
end

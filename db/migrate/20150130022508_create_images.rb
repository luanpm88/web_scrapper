class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.text :name
      t.text :dir
      t.integer :item_id
      t.text :source_url

      t.timestamps null: false
    end
  end
end

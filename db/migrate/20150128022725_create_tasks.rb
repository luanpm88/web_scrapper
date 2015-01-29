class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.text :name
      t.integer :page_id
      t.integer :category_id

      t.timestamps null: false
    end
  end
end

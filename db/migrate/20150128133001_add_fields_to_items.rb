class AddFieldsToItems < ActiveRecord::Migration
  def change
    add_column :items, :page_id, :integer
    add_column :items, :category_id, :integer
    add_column :items, :task_id, :integer
  end
end

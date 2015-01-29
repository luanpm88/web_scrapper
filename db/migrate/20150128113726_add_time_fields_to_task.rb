class AddTimeFieldsToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :min, :string
    add_column :tasks, :hour, :string
    add_column :tasks, :day, :string
    add_column :tasks, :month, :string
    add_column :tasks, :week, :string
  end
end

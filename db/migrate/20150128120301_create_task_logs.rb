class CreateTaskLogs < ActiveRecord::Migration
  def change
    create_table :task_logs do |t|
      t.integer :task_id
      t.integer :total
      t.integer :error
      t.integer :success

      t.timestamps null: false
    end
  end
end

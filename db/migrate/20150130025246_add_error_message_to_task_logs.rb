class AddErrorMessageToTaskLogs < ActiveRecord::Migration
  def change
    add_column :task_logs, :error_message, :text
  end
end

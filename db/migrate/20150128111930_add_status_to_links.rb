class AddStatusToLinks < ActiveRecord::Migration
  def change
    add_column :links, :status, :integer, :default => 0
  end
end

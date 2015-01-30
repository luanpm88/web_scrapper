class AddDetailsUpdatedToItem < ActiveRecord::Migration
  def change
    add_column :items, :details_updated, :integer, :default => 0
  end
end

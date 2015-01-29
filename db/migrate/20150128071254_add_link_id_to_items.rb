class AddLinkIdToItems < ActiveRecord::Migration
  def change
    add_column :items, :link_id, :integer
  end
end

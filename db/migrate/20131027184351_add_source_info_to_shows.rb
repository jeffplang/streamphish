class AddSourceInfoToShows < ActiveRecord::Migration
  def change
    add_column :shows, :source_info, :text
  end
end

class AddRemasteredFieldToShows < ActiveRecord::Migration
  def change
    add_column :shows, :remastered, :boolean, :default => false
  end
end

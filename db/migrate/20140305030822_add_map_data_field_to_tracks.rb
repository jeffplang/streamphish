class AddMapDataFieldToTracks < ActiveRecord::Migration
  def change
    add_column :tracks, :map, :json
  end
end

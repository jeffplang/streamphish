class AddSongCollectionIdColumnToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :song_collection_id, :integer
  end
end

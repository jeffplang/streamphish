class AddIdFieldToSongCollectionsSongs < ActiveRecord::Migration
  def change
    add_column :song_collections_songs, :id, :primary_key
  end
end

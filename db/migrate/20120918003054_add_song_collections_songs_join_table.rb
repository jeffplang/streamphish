class AddSongCollectionsSongsJoinTable < ActiveRecord::Migration
  def up
    create_table :song_collections_songs, :id => false do |t|
      t.references :song_collection
      t.references :song
    end

    SongCollection.reset_column_information
    Song.reset_column_information

    Song.all.each do |s| 
      sc = SongCollection.find s.song_collection_id
      sc.songs << s if sc
    end

    remove_column :songs, :song_collection_id
  end

  def down
    drop_table :song_collections_songs
    add_column :songs, :song_collection_id unless column_exists? :songs, :song_collection_id
  end
end

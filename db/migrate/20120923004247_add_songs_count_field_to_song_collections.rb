class AddSongsCountFieldToSongCollections < ActiveRecord::Migration
  def self.up
    add_column :song_collections, :songs_count, :integer, :default => 0

    SongCollection.reset_column_information
    SongCollection.all.each do |sc|
      sc.update_attribute :songs_count, sc.songs.length
    end
  end

  def self.down
    remove_column :song_collections, :songs_count if column_exists? :song_collections, :songs_count
  end
end

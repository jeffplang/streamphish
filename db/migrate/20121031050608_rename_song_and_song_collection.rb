class RenameSongAndSongCollection < ActiveRecord::Migration
  def up
    rename_table :songs, :tracks
    rename_table :song_collections, :songs
    rename_table :song_collections_songs, :songs_tracks

    rename_column :songs_tracks, :song_id, :track_id
    rename_column :songs_tracks, :song_collection_id, :song_id
    rename_column :songs, :songs_count, :tracks_count
    rename_column :section_markers, :song_id, :track_id

    File.rename(Rails.root + "public" + "system" + "songs",
                Rails.root + "public" + "system" + "tracks")

    Track.reset_column_information
    Track.all.each do |t|
      dir    = File.dirname(t.song_file.path)
      old_fn = Dir.glob("#{dir}/*").first

      File.rename old_fn, t.song_file.path
    end
  end

  def down
    rename_table :songs_tracks, :song_collections_songs
    rename_table :songs, :song_collections
    rename_table :tracks, :songs

    rename_column :song_collections_songs, :song_id, :song_collection_id
    rename_column :song_collections_songs, :track_id, :song_id
    rename_column :song_collections, :tracks_count, :songs_count
    rename_column :section_markers, :track_id, :song_id

    File.rename(Rails.root + "public" + "system" + "tracks",
                Rails.root + "public" + "system" + "songs")

    # You'll need to manually rename song files 
    # using code in up method depending on class 
    # name of Track.

  end
end

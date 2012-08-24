class AddSongFileFieldToSong < ActiveRecord::Migration
  def up
    add_attachment :songs, :song_file
  end

  def down
    remove_attachment :songs, :song_file
  end
end

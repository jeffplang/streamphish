class AddSongFileFieldToTrack < ActiveRecord::Migration
  def up
    add_attachment :tracks, :song_file
  end

  def down
    remove_attachment :tracks, :song_file
  end
end

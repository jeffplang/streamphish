class AddAlternativeAudioFileFieldsToTrack < ActiveRecord::Migration
  def up
    add_attachment :tracks, :song_file_m4a
    add_attachment :tracks, :song_file_ogx
  end

  def down
    remove_attachment :tracks, :song_file_m4a
    remove_attachment :tracks, :song_file_ogx
  end
end

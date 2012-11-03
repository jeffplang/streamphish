class SongsTrack < ActiveRecord::Base
  belongs_to :track
  belongs_to :song

  after_create do
    SongsTrack.find(self.song_id).increment!(:songs_count)
  end

  after_destroy do
    SongsTrack.find(self.song_id).decrement!(:songs_count)
  end
end
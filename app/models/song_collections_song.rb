class SongCollectionsSong < ActiveRecord::Base
  belongs_to :song
  belongs_to :song_collection

  after_create do
    SongCollection.find(self.song_collection_id).increment!(:songs_count)
  end

  after_destroy do
    SongCollection.find(self.song_collection_id).decrement!(:songs_count)
  end
end
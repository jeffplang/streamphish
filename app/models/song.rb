class Song < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :show_id, :title, :song_file, :song_collection_id

  belongs_to :show
  belongs_to :song_collection

  has_attached_file :song_file
  validates_attachment :song_file, :presence => true,
    :content_type => {:content_type => ['application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3']}

  validates_presence_of :show, :title, :song_collection
end

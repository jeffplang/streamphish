class SectionMarker < ActiveRecord::Base
  attr_accessible :title, :position, :song_id
  belongs_to :song

  validates_presence_of :title, :position, :song_id
end

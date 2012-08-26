class SectionMarker < ActiveRecord::Base
  attr_accessible :title, :position, :song_id
  belongs_to :song
end

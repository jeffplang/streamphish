class SectionMarker < ActiveRecord::Base
  attr_accessible :title, :position, :track_id
  belongs_to :track

  validates_presence_of :title, :position, :track_id
end

class ConcertSet < ActiveRecord::Base
  belongs_to :show
  has_many :tracks
  attr_accessible :show_id, :title, :position
end
class ConcertSet < ActiveRecord::Base
  belongs_to :show
  has_many :tracks, :dependent => :destroy
  attr_accessible :show_id, :show, :title, :position
end
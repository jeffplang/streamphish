class SongCollection < ActiveRecord::Base
  has_many :songs, :dependent => :destroy

  attr_accessible :title

  validates_presence_of :title

  extend FriendlyId
  friendly_id :title, :use => :slugged
end

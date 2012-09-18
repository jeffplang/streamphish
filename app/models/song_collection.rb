class SongCollection < ActiveRecord::Base
  has_and_belongs_to_many :songs

  attr_accessible :title

  validates_presence_of :title

  extend FriendlyId
  friendly_id :title, :use => :slugged

  # include PgSearch
  # pg_search_scope :kinda_matching,
  #                 :against => :title, 
  #                 :using => {
  #                   tsearch: {
  #                     any_word: true,
  #                     normalization: 8
  #                   }
  #                 }
end

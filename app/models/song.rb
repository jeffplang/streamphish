class Song < ActiveRecord::Base
  attr_accessible :title, :songs_count

  has_and_belongs_to_many :tracks
  scope :random, lambda { |amt| where('tracks_count > 0').order('RANDOM()').limit(amt) }

  validates_presence_of :title

  extend FriendlyId
  friendly_id :title, :use => :slugged

  include PgSearch
  pg_search_scope :kinda_matching,
                  :against => :title, 
                  :using => {
                    tsearch: {
                      any_word: true,
                      normalization: 16
                    }
                  }

  def bb_json
    Jbuilder.encode do |json|
      json.(self, :title)
      # TODO: Figure out how to get tracks eager loaded...weirdness going on with the HABTM relationship
      json.tracks self.tracks.includes(:show).chronological do |track|
        json.(track, :id, :title, :position, :duration, :file_url, :file_url, :slug)
        json.show track.show, :show_date, :location
      end
    end
  end
end

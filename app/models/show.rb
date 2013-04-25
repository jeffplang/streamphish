class Show < ActiveRecord::Base
  attr_accessible :show_date, :location, :sbd, :remastered

  has_many :concert_sets, :dependent => :destroy
  has_many :tracks, :through => :concert_sets, :dependent => :destroy

  scope :for_year, lambda { |year|
    if year == '83-87'
      where('show_date between ? and ?', 
              Date.new(1983).beginning_of_year, 
              Date.new(1987).end_of_year).order(:show_date)
    else
      date = Date.new(year.to_i)
      where('show_date between ? and ?', 
              date.beginning_of_year, 
              date.end_of_year).order(:show_date)
    end
  }

  validates_presence_of :show_date, :location

  extend FriendlyId
  friendly_id :show_date

  def to_s
    "#{show_date.strftime('%m-%d-%Y')} - #{location}" if show_date && location
  end
  alias_method :title, :to_s # for rails admin

  def bb_json
    Jbuilder.encode do |json|
      json.(self, :id, :location, :remastered, :sbd, :show_date)
      json.sets self.concert_sets do |concert_set|
        json.(concert_set, :title)
        json.tracks concert_set.tracks.includes(:songs).order(:position) do |track|
          json.(track, :id, :title, :position, :duration, :file_url, :slug)
        end
      end
    end
  end
end

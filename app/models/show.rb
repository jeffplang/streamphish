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
  friendly_id :show_date, use: [:finders]

  def to_s
    "#{show_date.strftime('%m-%d-%Y')} - #{location}" if show_date && location
  end

  def set_break_indexes
    concert_sets.each_with_object([]) do |set, indexes|
      indexes << (indexes.last ? indexes.last + set.tracks.length : 0)
    end
  end

  alias_method :title, :to_s # for rails admin

end

class Show < ActiveRecord::Base
  attr_accessible :show_date, :location

  has_many :songs

  extend FriendlyId
  friendly_id :show_date

  def to_s
    "#{show_date} - #{location}"
  end
  alias_method :title, :to_s # for rails admin

  def to_page_title_s
    "#{show_date.strftime('%m-%d-%Y')} - #{location}"
  end
end

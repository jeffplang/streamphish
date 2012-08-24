class Show < ActiveRecord::Base
  attr_accessible :show_date, :location

  has_many :songs

  def to_s
    "#{show_date} - #{location}"
  end
end

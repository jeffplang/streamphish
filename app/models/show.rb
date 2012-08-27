class Show < ActiveRecord::Base
  attr_accessible :show_date, :location

  has_many :songs

  def to_s
    "#{show_date} - #{location}"
  end
  alias_method :title, :to_s # for rails admin
end

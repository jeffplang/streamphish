class PagesController < ApplicationController
  def index
    get_years
    @songs = Song.random 18
  end

  def years
    get_years
  end
  
  def venues
    @venues = Venue.order(:name).all
  end
  
  def tours
    @tours = Tour.order(:name).all
  end
  
  def cities
    @cities = Venue.order(:city, :state).all.map(&:location).uniq
  end

  def states
    @states = Venue.order(:state).all.map(&:state).uniq
  end
  
  def countries
    @countries = Venue.order(:country).all.map(&:country).uniq
  end
end

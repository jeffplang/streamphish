class PagesController < ApplicationController
  def index
    get_years
    @songs = Song.random 18
    respond_to do |format|
      format.html
      format.json do
        render :json => {
          :years => years_map,
          :songs => songs_map
        }
      end
    end
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

  private

  def years_map
    @years.map do |year|
      { :year => year, 
        :isEmpty => Show.for_year(year).count.zero? }.merge(random_bg_and_fg)
    end
  end

  def songs_map
    @songs.map do |song|
      { :title => song.title, 
        :url => song_path(song) }.merge(random_bg_and_fg)
    end
  end

  def random_bg_and_fg
    bg = Color::RGB.new(rand(256), rand(256), rand(256))
    palette = Color::Palette::MonoContrast.new(bg)
    
    { :bg => palette.background[-2].html, :fg => palette.foreground[-5].html }
  end

end

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

  private

  def years_map
    @years.map do |year|
      { :year => year, :isEmpty => Show.for_year(year).count.zero? }
    end
  end

  def songs_map
    @songs.map do |song|
      { :title => song.title, :url => song_path(song) }
    end
  end
end
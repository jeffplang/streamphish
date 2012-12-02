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
      bg      = Color::RGB.new(rand(256), rand(256), rand(256))
      palette = Color::Palette::MonoContrast.new(bg)

      { :year => year, 
        :isEmpty => Show.for_year(year).count.zero?,
        :bg => palette.background[-2].html,
        :fg => palette.foreground[-5].html }
    end
  end

  def songs_map
    @songs.map do |song|
      { :title => song.title, :url => song_path(song) }
    end
  end
end
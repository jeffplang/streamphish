class PagesController < ApplicationController
  def index
    get_years
    respond_to do |format|
      format.html do
        @years = years_map
      end
      format.json do
        @songs = Song.random 18

        render :json => {
          :years => get_years,
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
      { :year => year }
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
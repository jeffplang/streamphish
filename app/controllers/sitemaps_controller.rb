class SitemapsController < ApplicationController
  def index
  end

  def sections
  end

  def songs
    @songs = Song.where('tracks_count > 0').order(:title)
  end

  def shows_by_year
    @shows = Show.for_year params[:year]
  end

  def show_by_date(date)
  end
end

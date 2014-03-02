class SongsController < ApplicationController
  def index
    @songs = Song.where('tracks_count > 0').order(:title)
  end

  def show
    @song = Song.includes(:tracks).find params[:id]
  end
end

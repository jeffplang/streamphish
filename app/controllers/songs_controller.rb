class SongsController < ApplicationController

  caches_action :index, :show

  def index
    @songs = Song.where('tracks_count > 0').order(:title)
  end

  def show
    @song = Song.includes(:tracks).find params[:id]
    @tracks = @song.tracks.includes(:show).chronological
  end
end

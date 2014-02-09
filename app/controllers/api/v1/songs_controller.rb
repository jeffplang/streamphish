class Api::V1::SongsController < ApplicationController

  caches_action :index, :show

  def index
    @songs = Song.where('tracks_count > 0').order(:title)
    respond_to do |format|
      # format.html
      format.json { render :json => @songs.to_json(:only => [:title, :slug]) }
    end
  end

  def show
    @song = Song.includes(:tracks).find params[:id]
    respond_to do |format|
      # format.html
      format.json do 
        render :json => @song.bb_json
      end
    end
  end
end

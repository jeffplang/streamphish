class SongsController < ApplicationController
  def index
    @songs = Song.where('tracks_count > 0').order(:title)
    respond_to do |format|
      format.html
      format.json { render :json => @songs.to_json(:only => [:title, :slug]) }
    end
  end

  def show
    @song = Song.find params[:id]
    respond_to do |format|
      format.html
      format.json do 
        render :json => @song.to_json(
          :only => [:title], 
          :include => {
            :tracks => { 
              :methods => [:file_url, :slug],
              :only => [:title, :position, :duration], 
              :include => {
                :show => { :only => [:show_date, :location] }
              }
            }
          }
        )
      end
    end
  end
  
end

class SongsController < ApplicationController

  def index
    get_songs
  end

  def new
    @song = Song.new
    get_shows
  end

  def create
    @song = Song.create(params[:song])
    if @song.save
      flash[:notice] = "Song #{@song.title} created."
      redirect_to songs_path
    else
      flash[:notice] = @song.errors.full_messages.join(', ')
      get_shows
      render :new
    end
  end

  protected

  def get_shows
    @shows ||= Show.all
  end

  def get_songs
    @songs ||= Song.all
  end
end
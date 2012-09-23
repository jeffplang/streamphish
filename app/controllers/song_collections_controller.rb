class SongCollectionsController < ApplicationController
  def index
    @song_collections = SongCollection.where('songs_count > 0').order(:title)
  end

  def show
    @song_collection = SongCollection.find params[:id]
  end
end

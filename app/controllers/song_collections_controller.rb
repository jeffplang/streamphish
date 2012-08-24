class SongCollectionsController < ApplicationController
  def index
    @song_collections = SongCollection.all    
  end

  def show
    @song_collection = SongCollection.find_by_slug(params[:id])
  end
end

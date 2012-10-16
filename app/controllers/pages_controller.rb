class PagesController < ApplicationController
  def index
    get_years
    @song_collections = SongCollection.random 18
  end

  def years
    get_years
  end
end

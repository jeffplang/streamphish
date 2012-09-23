class PagesController < ApplicationController
  def index
    @years = ['83-87'] + (1988..2012).to_a
    @song_collections = SongCollection.random 18
  end
end

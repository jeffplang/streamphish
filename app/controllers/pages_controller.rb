class PagesController < ApplicationController
  def index
    get_years
    @songs = Song.random 18
  end

  def years
    get_years
  end
end

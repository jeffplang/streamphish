class PagesController < ApplicationController
  def index
    @years = ['83-87'] + (1988..2012).to_a
    @left_values = incremental_vals_for(@years, 50, 64)
    @top_values = incremental_vals_for(@years, 0, 15)

    @song_collections = SongCollection.random(25)
  end

  private

  def incremental_vals_for(array, min, max, initial=0)
    array[1..-1].inject([initial]) do |vals, year| 
      vals << vals.last + rand(min..max)
    end
  end
end

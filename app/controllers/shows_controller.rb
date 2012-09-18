class ShowsController < ApplicationController
  def index
    @years = ['83-87'] + (1988..2012).to_a
    @left_values = incremental_vals_for(@years, 50, 64)
    @top_values = incremental_vals_for(@years, 0, 15)
  end

  def show
    @show = Show.find params[:id]
  end

  def new
    @show = Show.new
  end

  def create
    @show = Show.create(params[:show])
    if @show
      redirect_to shows_path
    end
  end

  def destroy
    show = Show.find params[:id]
    if show.destroy
      redirect_to shows_path
    end
  end

  private

  def incremental_vals_for(array, min, max, initial=0)
    array[1..-1].inject([initial]) do |vals, year| 
      vals << vals.last + rand(min..max)
    end
  end
end
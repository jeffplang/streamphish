class ShowsController < ApplicationController
  def index
    if params[:year]
      get_shows_by_year
    else
      @years = ['83-87'] + (1988..2012).to_a
      @left_values = incremental_vals_for(@years, 50, 64)
      @top_values = incremental_vals_for(@years, 0, 15)
    end
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

  def get_shows_by_year
    if params[:year] == '83-87'
      @year = params[:year]
      @shows = Show.where("show_date between ? and ?", 
                          Date.new(1983).beginning_of_year, 
                          Date.new(1987).end_of_year)
    else
      @year = params[:year].to_i
      @shows = Show.where("show_date between ? and ?", 
                          Date.new(@year).beginning_of_year, 
                          Date.new(@year).end_of_year)
    end
    render "shows_by_year"
  end
end
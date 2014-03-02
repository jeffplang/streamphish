class ShowsController < ApplicationController
  def index
  end

  def show
    if is_valid_year?(params[:id])
      get_shows_by_year
      render 'shows_by_year'
    else
      @show = Show.includes(:tracks => :songs).find(params[:id])
    end
  end

  private

  def get_shows_by_year
    @year = params[:id]
    @shows = Show.for_year @year
  end

  def is_valid_year?(date_str)
    date_str == '83-87' || date_str.length == 4
  end

end

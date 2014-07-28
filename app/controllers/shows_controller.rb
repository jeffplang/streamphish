class ShowsController < ApplicationController

  # caches_action :show, :cache_path => Proc.new { |c| show_url(id: c.params[:id]).gsub(/^http\:\/\//, '') }

  def show
    if is_valid_year?(params[:id])
      get_shows_by_year
      render 'shows_by_year'
    else
      @show = Show.includes(:tracks => :songs).find(params[:id])

      set_og
    end
  end

  private

  def set_og
    @og = { 
      title: "#{@show.show_date.strftime('%m/%d/%Y')} #{@show.location}",
      url: request.url
    }

    if params[:song]
      @song = @show.tracks.find_by_slug(params[:song])
      @og[:title] = @song.title if @song
    end
  end

  def get_shows_by_year
    @year = params[:id]
    @shows = Show.for_year @year
  end

  def is_valid_year?(date_str)
    date_str == '83-87' || date_str.length == 4
  end

end

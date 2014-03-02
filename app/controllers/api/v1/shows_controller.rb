class Api::V1::ShowsController < Api::V1Controller

  caches_action :show
  caches_action :index, :cache_path => Proc.new { |c| c.params.slice :controller, :action, :year },
                        :if => Proc.new { request.format.json? }

  def index
    get_shows_by_year
  end

  def show
    @show = Show.includes(:tracks => :songs).find(params[:id])
  end

  private

  def get_shows_by_year
    @year = params[:year]
    @shows = Show.for_year @year
  end
end

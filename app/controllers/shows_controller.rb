class ShowsController < ApplicationController
  def index
    redirect_to root_path and return unless params[:year]

    get_shows_by_year

    respond_to do |format|
      format.html { render "shows_by_year" }
      format.json { render :json => @shows }
    end
  end

  def show
    @show = Show.includes(:tracks => :songs).find(params[:id])

    respond_to do |format|
      format.html
      format.json do 
        render :json => @show.bb_json
      end
    end
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

  def get_shows_by_year
    @year = params[:year]
    @shows = Show.for_year @year
  end
end
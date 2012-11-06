class ShowsController < ApplicationController
  def index
    if params[:year]
      get_shows_by_year
      render "shows_by_year"
    else
      redirect_to root_path
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
  
  # Provide the tracks as a downloadable ZIP
  def download
    tracks = []
    show = Show.where("show_date = ?", params[:id]).first
    if show
      tracks = show.tracks.order(:position).all
      data = Track.downloadable(tracks)
      raise data.size.inspect
      if tracks.size > 1
        send_data data, :type => "application/zip", :disposition => "attachment", :filename => "Phish " + show.show_date.to_s + " " + show.location + ".zip"
      else
        send_data data, :type => "audio/mpeg", :disposition => "attachment", :filename => tracks.first.title + ".mp3"
      end
    end
  end

  private

  def get_shows_by_year
    @year = params[:year]
    @shows = Show.for_year @year
  end
end
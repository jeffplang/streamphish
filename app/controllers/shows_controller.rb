class ShowsController < ApplicationController
  
  include AlbumUtils
  
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
        render :json => @show.to_json(
          :include => {
            :tracks => { :methods => [:file_url, :slug], :only => [:title, :position, :duration] }
          }
        )
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
  
  # Respond to an AJAX request to create an album
  def request_download
    show = Show.find_by_show_date(params[:id])
    # show.poodle
    if show
      album_tracks = show.tracks.order(:position).all
      # Prune away tracks if specific set is being called
      if params[:set].present? and show.tracks.map(&:set).include? params[:set]
        # If the last set of the show is being requested, include encore tracks
        album_tracks.reject! { |track| /^E\d?$/.match track.set } unless show.last_set == params[:set].to_i
        album_tracks.reject! { |track| /^\d$/.match track.set and track.set != params[:set] }
        album_name = "#{show.show_date.to_s} #{album_tracks.first.set_name}" if album_tracks.any?
      else
        album_name = show.show_date.to_s
      end
      if album_tracks.any?
        render :json => album_status(album_tracks, album_name)
      else
        render :json => { :status => "Invalid album request" }
      end
    else
      render :json => { :status => "Invalid show" }
    end
  end

  private

  def get_shows_by_year
    @year = params[:year]
    @shows = Show.for_year @year
  end
end
class ToursController < ApplicationController

  def index
    @tours = Tour.order(:name).all
    respond_to do |format|
      format.html
      format.json do
        render :json => @tours
      end
    end
  end
  
  def show
    @tour = Tour.find params[:id]
    respond_to do |format|
      format.html
      format.json do
        render :json => @tour.to_json(
          :only => [:title], 
          :include => {
            :shows => { :only => [:show_date, :location] }
          }
        )
      end
    end
  end
  
end

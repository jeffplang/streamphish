class TracksController < ApplicationController
  
  # Provide the track as a downloadable MP3
  def download
    tracks = []
    tracks << Track.find(params[:id])
    send_data Track.downloadable(tracks), :type => "audio/mpeg", :disposition => "attachment", :filename => tracks.first.title + ".mp3"
  end
  
end

class TracksController < ApplicationController
  
  include DownloadableTracks
  
  # Provide the track as a downloadable MP3
  def download
    tracks = []
    tracks << Track.find(params[:id])
    download_tracks(tracks)
  end
  
end

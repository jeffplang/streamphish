class TracksController < ApplicationController
  
  # Provide the track as a downloadable MP3
  def download
    track = Track.find(params[:id])
    send_file track.song_file.path, :type => "audio/mpeg", :disposition => "attachment", :filename => (track.title + '.mp3'), :length => File.size(track.song_file.path)
  end
  
end

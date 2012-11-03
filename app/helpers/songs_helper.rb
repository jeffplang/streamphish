module SongsHelper
  def marker_position_css(marker, track)
    percent_in = (marker.position.to_f / track.duration.to_f * 100)
   
    "#{percent_in}%"
  end
end
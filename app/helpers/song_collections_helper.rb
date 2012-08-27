module SongCollectionsHelper
  def marker_position_css(marker, song)
    percent_in = (marker.position.to_f / song.duration.to_f * 100).round
   
    "#{percent_in}%"
  end
end
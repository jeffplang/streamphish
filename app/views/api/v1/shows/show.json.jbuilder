json.(@show, :id, :location, :remastered, :sbd, :show_date, :source_info)

json.sets @show.concert_sets do |concert_set|
  json.(concert_set, :title)
  json.tracks concert_set.tracks.includes(:songs).order(:position) do |track|
    json.(track, :id, :title, :position, :duration, :slug)
    json.map track.map if track.map
    json.file_url "http://assets.phishtracks.com#{track.file_url}"
    json.file_url_m4a "http://assets.phishtracks.com#{track.song_file_m4a.to_s}" if track.song_file_m4a.present?
    json.file_url_ogx "http://assets.phishtracks.com#{track.song_file_ogx.to_s}" if track.song_file_ogx.present?
  end
end

json.prev_show @show.prev_show.try(:show_date)
json.next_show @show.next_show.try(:show_date)

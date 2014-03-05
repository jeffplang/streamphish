json.(@show, :id, :location, :remastered, :sbd, :show_date, :source_info)

json.sets @show.concert_sets do |concert_set|
  json.(concert_set, :title)
  json.tracks concert_set.tracks.includes(:songs).order(:position) do |track|
    json.(track, :id, :title, :position, :duration, :slug)
    json.map track.map if track.map
    json.file_url "http://assets.phishtracks.com#{track.file_url}"
  end
end

json.id @song.slug
json.(@song, :title)

json.tracks @song.tracks.includes(:show).chronological do |track|
  json.(track, :id, :title, :position, :duration, :file_url, :file_url, :slug)
  json.show track.show, :show_date, :location
end

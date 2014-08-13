json.id @song.slug
json.(@song, :title)

json.tracks @tracks do |track|
  json.(track, :id, :title, :position, :duration, :file_url, :file_url, :slug)
  json.show track.show, :show_date, :location
end

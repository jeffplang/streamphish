json.years @years
json.songs @songs do |song|
  json.title song.title
  json.url song_path(song)
end

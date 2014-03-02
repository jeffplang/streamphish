json.array! @songs do |song|
  json.(song, :title, :slug)
end

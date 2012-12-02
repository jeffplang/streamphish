module AlbumUtils
  
  # Check the status of album creation, spawning a new job if required
  # Return a hash including status and url of download if complete
  def album_status(tracks, album_name, is_custom_playlist=false)
    checksum = album_checksum(tracks, album_name)
    album = Album.find_by_md5(checksum)
    if album
      album.update_attributes(:updated_at => Time.now)
      if album.completed_at
        status = 'Ready'
      else
        status = 'Processing'
      end
    else
      status = 'Enqueuing'
      album = Album.create(:name => album_name, :md5 => checksum, :is_custom_playlist => is_custom_playlist)
      # Create zipfile asynchronously
      album.create_zip_file(tracks)
    end
    { :status => status, :url => "/download/#{checksum}" }
  end
  
  protected
  
  # Generate an MD5 checksum of an album using its tracks' song_file paths and album_name
  # Album_name will differentiate two identical playlists with different names (for unique id3 tagging)
  def album_checksum(tracks, album_name)
    digest = Digest::MD5.new()
    tracks.each { |track| digest << track.song_file.path }
    digest << album_name
    digest.to_s
  end
  

end
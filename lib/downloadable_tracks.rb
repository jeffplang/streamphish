module DownloadableTracks
  
  require 'taglib'      # For setting ID3 tags on MP3s
  
  # protected
  
  # Provide a hash including status and checksum of created album or shorter string feedback otherwise
  def album_status(tracks, custom_album_name=nil)
    checksum = album_checksum(tracks, custom_album_name)
    zipfile_path = "#{ALBUM_CACHE_PATH}#{checksum}.zip"
    if !File.exists? zipfile_path
      #   start job if it hasn't already
      status = 'Starting'
    else
      # if job done
        status = 'Ready'
      # else
      # 'ongoing'
      #end
    end
    { :status => status, :url => "/download/#{checksum}" }
  end
  
  # Provide a set of tracks ("album") as a zipped file
  # Set the ID3 tags on the tracks to the album context
  def create_album(tracks, custom_album_name=nil)
    
    checksum = album_checksum(tracks, custom_album_name)
    zipfile_path = "#{ALBUM_CACHE_PATH}#{checksum}.zip"
    
    # Send file immediately if it exists in cache
    if File.exists?(zipfile_path)
      # Update mtime of cache file
      FileUtils.touch zipfile_path
      # Send file to user
      album_filename = "Phish - " + (custom_album_name ? "#{custom_album_name}" : tracks.first.show.show_date.to_s)
      send_file zipfile_path, :type => "application/zip", :disposition => "attachment", :filename => album_filename, :length => File.size(zipfile_path)
    else

      # TODO do the following in a resque job

      ##################################
      # Make a temporary directory and make copies of each track
      # Set ID3 tags in the process (livephish style)
      tmpdir = "#{TMP_PATH}album_#{checksum}/"
      Dir.mkdir tmpdir
      tracks.each_with_index do |track, i|
        tmpfile_path = tmpdir + ((tracks.size >= 100) ? "%03d" : "%02d" % (i + 1)) + " - " + track.title + ".mp3"
        FileUtils.cp track.song_file.path, tmpfile_path
        # tmpfile_paths << tmpfile_path
        TagLib::MPEG::File.open(tmpfile_path) do |file|
          # Set basic ID3 tags
          tag = file.id3v2_tag
          if tag
            # Add the date/set to the song title if custom album name given
            if custom_album_name
              tag.title = "#{track.title} (#{track.show.show_date} #{track.set_album_abbreviation})"
              tag.album = album_name
            end
            tag.track = i + 1
        
            # Don't change the defaults (as set by rake tracks:save_default_id3)
            # tag.title = track.title
            # tag.artist = "Phish"
            # tag.year = track.show.show_date.strftime("%Y").to_i
            # tag.genre = "Rock"
            # tag.comment = "Visit phishtracks.net for free Phish audio"
            # Add cover art
            # apic = TagLib::ID3v2::AttachedPictureFrame.new
            # apic.mime_type = "image/jpeg"
            # apic.description = "Cover"
            # apic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
            # apic.picture = File.open(Rails.root.to_s + '/app/assets/images/cover_generic.jpg', 'rb') { |f| f.read }
            # tag.add_frame(apic)
        
            # Save
            file.save
          end
        end
      end

      # Remove old files if not enough free space in album cache (assuming no compression)
      album_size = 0
      tracks.each { |track| album_size += track.song_file.size}
      while album_size > cache_space_left and !cached_files.empty? do
        files = cached_files.sort_by { |file| File.mtime file }
        File.delete(files.first) unless files.empty?
      end
      
      # Create zipfile in album cache
      system "cd #{tmpdir} && zip #{zipfile_path} ./*"
    
      # Delete temporary working directory
      FileUtils.rm_rf tmpdir
      
      raise "file is ready"
      
    end

  end
  
  # Return bytes left in album cache
  def cache_space_left
    size = 0
    Dir.glob("#{ALBUM_CACHE_PATH}*").each { |file| size += File.size file if File.file? file }
    ALBUM_CACHE_SIZE - size
  end
  
  # Return array of paths to existing cached albums
  def cached_files
    Dir.glob("#{ALBUM_CACHE_PATH}*").map { |file| file if File.file? file }
  end
  
  # Generate an MD5 checksum of an album using its tracks' song_file paths
  # Album_name will differentiate two identical playlists with different names
  def album_checksum(tracks, custom_album_name=nil)
    digest = Digest::MD5.new()
    tracks.each { |track| digest << track.song_file.path }
    digest << custom_album_name if custom_album_name
    digest.to_s
  end
  

end
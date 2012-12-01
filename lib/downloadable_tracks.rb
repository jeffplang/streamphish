module DownloadableTracks
  
  require 'taglib'      # For setting ID3 tags on MP3s
  require 'zip/zip'     # For compressing multiple MP3s into one ZIP file
  
  # Provide a filestream of a single MP3 or ZIP (multiple MP3s)
  def download_tracks(tracks, album_name=nil)
    
    tmpfile_paths = []
    zipfile_path = ''
    tmpdir = ''

    ##################################
    # Make a temporary directory and make copies of each track
    # Set ID3 tags in the process (livephish style)
    tmpdir = Rails.root.to_s + '/tmp/download_' + (0...30).map{97.+(rand(26)).chr}.join + '/'
    Dir.mkdir tmpdir
    tracks.each_with_index do |track, i|
      tmpfile_path = tmpdir + ((tracks.size >= 100) ? "%03d" : "%02d" % (i + 1)) + " - " + track.title + ".mp3"
      FileUtils.cp track.song_file.path, tmpfile_path
      tmpfile_paths << tmpfile_path
      TagLib::MPEG::File.open(tmpfile_path) do |file|
        # Set basic ID3 tags
        tag = file.id3v2_tag
        if tag
          album_name ||= how.show_date.to_s + " " + set_album_abbreviation + " " + show.location
          tag.album = album_name
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

    ####################################
    # Send a zipfile to the user
    # zipfile_path = tmpdir + 'playlist.zip'
    # Zip::ZipFile.open(zipfile_path, 'w') do |zipfile|
    #   Dir["#{tmpdir}**/**"].reject { |f| f == zipfile_path }.each do |file|
    #      zipfile.add file.sub(tmpdir, ''), file
    #    end
    #  end
    # send_file zipfile_path, :type => "application/zip", :disposition => "attachment", :filename => filename, :length => File.size(zipfile_path)
    # 
    # ####################################
    # # Delete temporary directory / files
    # tmpfile_paths.each { |tmpfile| File.delete tmpfile }
    # File.delete zipfile_path if File.exists?(zipfile_path)
    # Dir.delete tmpdir

  end

end
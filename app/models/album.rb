class Album < ActiveRecord::Base
  
  require 'taglib'
  
  #########################
  # Attributes & Constants
  #########################
  FILE_NAME_HASH_SECRET = "CROUOPQNDKUCBVYTQYQLUSKCOMJAQFEWXMEX"
  attr_accessible :name, :md5, :is_custom_playlist, :completed_at, :updated_at

  has_attached_file :zip_file,
    :url => "/system/:class/:attachment/:hash.:extension",
    :hash_secret => FILE_NAME_HASH_SECRET
  
  def self.completed
    where("completed_at IS NOT NULL")
  end
  
  # Create the zipfile for an album, setting id3 tags in the process
  def create_zip_file(tracks)
    tmpdir = "#{TMP_PATH}album_#{md5}/"
    # Delete temporary working directory (# TODO FIX THIS..shouldn't need it)
    # FileUtils.rm_rf tmpdir
    Dir.mkdir tmpdir
    tracks.each_with_index do |track, i|
      tmpfile_path = tmpdir + ((tracks.size >= 100) ? "%03d" : "%02d" % (i + 1)) + " - " + track.title + ".mp3"
      FileUtils.cp track.song_file.path, tmpfile_path
      TagLib::MPEG::File.open(tmpfile_path) do |file|
        # Set basic ID3 tags
        tag = file.id3v2_tag
        if tag
          # Add the date/set to the song title if the album is a custom playlist
          if is_custom_playlist
            tag.title = "#{track.title} (#{track.show.show_date} #{track.set_album_abbreviation})"
            tag.album = name
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

    # Remove existing albums if not enough free space in cache (assuming no compression)
    album_size = 0
    tracks.each { |track| album_size += track.song_file.size}
    existing_albums = Album.completed.order(:updated_at).all
    while album_size > cache_space_left and existing_albums.any? do
      existing_albums.shift.destroy
    end
      
    # Create zipfile in working directory and apply as paperclip attachment to album
    tmpfile = "#{tmpdir}#{md5}.zip"
    system "cd #{tmpdir} && zip #{tmpfile} ./*"
    self.zip_file = File.open tmpfile
    
    # Delete temporary working directory
    FileUtils.rm_rf tmpdir

    # Set album as completed
    update_attributes(:completed_at => Time.now)
      
  end
  
  # Return bytes left in album cache
  def cache_space_left
    size = 0
    albums = Album.completed.order(:updated_at).all
    albums.each { |album| size += album.zip_file.size }
    ALBUM_CACHE_SIZE - size
  end
  
end

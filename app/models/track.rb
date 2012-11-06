class Track < ActiveRecord::Base
  
  #########################
  # Requires & Includes
  #########################
  require 'taglib'              # For reading/writing ID3 tags
  require 'zip/zip'             # For compressing multiple files into a single ZIP

  #########################
  # Attributes & Constants
  #########################
  FILE_NAME_HASH_SECRET = "CROUOPQNDKUCBVYTQYQLUSKCOMJAQFEWXMEX"
  attr_accessible :show_id, :title, :position, :song_file, :song_ids

  has_attached_file :song_file,
    :url => "/system/:class/:attachment/:id_partition/:style/:hash.:extension",
    :hash_secret => FILE_NAME_HASH_SECRET

  ########################
  # Associations & Scopes
  ########################
  has_many :songs_tracks, :dependent => :destroy
  has_many :songs, :through => :songs_tracks
  has_many :section_markers, :dependent => :destroy
  belongs_to :show
  
  scope :chronological, order('shows.show_date ASC').joins(:show)

  ##############
  # Validations
  ##############
  validates_attachment :song_file, :presence => true,
    :content_type => {:content_type => ['application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3']}
  validates_presence_of :show, :title, :position
  validates_uniqueness_of :position, :scope => :show_id
  validate :require_at_least_one_song

  ############
  # Callbacks
  ############
  before_validation :populate_song, :populate_position
  after_save :set_duration

  protected
  
  def set_duration
    unless self.duration # this won't record the correct duration if we're uploading a new file
      Mp3Info.open song_file.path do |mp3|
        self.duration = (mp3.length * 1000).round
        save
      end
    end
  end

  def populate_song
    if self.songs.empty?
      sc = Song.where 'lower(title) = ?', self.title.downcase
      self.songs << sc if sc
    end
  end

  def populate_position
    # If we don't have a position and there is at least 1 previous song in the show
    if !self.position && !(last_song = Track.where(:show_id => show.id).last).nil?
      self.position = last_song.position + 1
    elsif !self.position
      self.position = 1
    end
  end

  def require_at_least_one_song
    errors.add(:songs, "Please add at least one song") if songs.empty?
  end
  
  # Provide a filestream of a single MP3 or ZIP (multiple MP3s)
  def self.downloadable(tracks)
    
    tmpfile_paths = []
    zipfile_path = ''
    tmpdir = ''

    ##################################
    # Make a temporary directory and make copies of each track, setting ID3 tags in the process
    tmpdir = Rails.root.to_s + '/tmp/download_' + (0...30).map{97.+(rand(26)).chr}.join + '/'
    Dir.mkdir tmpdir
    tracks.each_with_index do |track, i|
      if tracks.size > 1
        # Multiple mp3s should be ordered in filesystem as "01 - Title.mp3", "02 - Title2.mp3", etc for zipping
        tmpfile_path = tmpdir + ((tracks.size >= 100) ? "%03d" : "%02d" % (i + 1)) + " - " + track.title + ".mp3"
      else
        tmpfile_path = tmpdir + track.title + '.mp3'
      end
      FileUtils.cp track.song_file.path, tmpfile_path
      tmpfile_paths << tmpfile_path
      TagLib::MPEG::File.open(tmpfile_path) do |file|
        # Set basic ID3 tags
        tag = file.id3v2_tag
        tag.title = track.title
        tag.artist = "Phish"
        tag.album = track.show.show_date.to_s + " " + track.show.location
        tag.year = track.show.show_date.strftime("%Y").to_i
        tag.track = i + 1
        tag.genre = "Rock"
        tag.comment = "Visit phishtracks.net for free legal Phish audio"
        # Add cover art
        apic = TagLib::ID3v2::AttachedPictureFrame.new
        apic.mime_type = "image/jpeg"
        apic.description = "Cover"
        apic.type = TagLib::ID3v2::AttachedPictureFrame::FrontCover
        apic.picture = File.open(Rails.root.to_s + '/app/assets/images/cover_generic.jpg', 'rb') { |f| f.read }
        tag.add_frame(apic)
        # Save
        file.save
      end
    end

    ####################################
    # Provide the contents of the mp3 or zipfile
    if tracks.size > 1
      # Zip up all the files if requesting multiple
      zipfile_path = tmpdir + 'playlist.zip'
      Zip::ZipFile.open(zipfile_path, 'w') do |zipfile|
        Dir["#{tmpdir}**/**"].reject { |f| f == zipfile_path }.each do |file|
           zipfile.add file.sub(tmpdir, ''), file
         end
       end
       contents = File.read(zipfile_path)
    else
      contents = File.read(tmpfile_paths.first)
    end
    
    ####################################
    # Delete temporary directory / files
    tmpfile_paths.each { |tmpfile| File.delete tmpfile }
    File.delete zipfile_path if File.exists?(zipfile_path)
    Dir.delete tmpdir
    
    ######################
    # Return file contents
    contents
    
  end
end

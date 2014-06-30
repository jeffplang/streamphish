class Track < ActiveRecord::Base

  #########################
  # Attributes & Constants
  #########################
  FILE_NAME_HASH_SECRET = "CROUOPQNDKUCBVYTQYQLUSKCOMJAQFEWXMEX"
  attr_accessible :concert_set_id, :title, :position, :song_file, :song_ids, :show

  extend FriendlyId
  friendly_id :title, use: [:slugged, :scoped], scope: :show

  has_attached_file :song_file,
    :url => "/system/:class/:attachment/:id_partition/:style/:hash.:extension",
    :hash_secret => FILE_NAME_HASH_SECRET

  has_attached_file :song_file_m4a,
    :url => "/system/:class/:attachment/:id_partition/:style/:hash.:extension",
    :hash_secret => FILE_NAME_HASH_SECRET

  has_attached_file :song_file_ogx,
    :url => "/system/:class/:attachment/:id_partition/:style/:hash.:extension",
    :hash_secret => FILE_NAME_HASH_SECRET


  ########################
  # Associations & Scopes
  ########################
  has_many :songs_tracks, dependent: :destroy
  has_many :songs, through: :songs_tracks
  has_many :section_markers, dependent: :destroy
  belongs_to :concert_set
  # delegate :show, :to => :concert_set
  belongs_to :show
  
  # default_scope order('position')
  scope :chronological, Proc.new{ order('shows.show_date ASC').joins(:show) }

  ##############
  # Validations
  ##############
  validates_attachment :song_file, presence: true,
    content_type: { content_type: ['application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3', 'application/ogg', 'audio/mp4'] }
  validates_attachment :song_file_m4a, content_type: { content_type: ['audio/mp4'] }
  validates_attachment :song_file_ogx, content_type: { content_type: ['application/ogg'] }
  validates_presence_of :show, :title, :position
  validates_uniqueness_of :position, scope: :show_id
  validate :require_at_least_one_song

  ############
  # Callbacks
  ############
  before_validation :populate_song, :populate_position
  before_save :set_duration

  def file_url
    song_file.to_s
  end

  protected

  def set_duration
    if song_file.dirty?
      Mp3Info.open song_file.queued_for_write[:original].path do |mp3| 
        self.duration = (mp3.length * 1000).round
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

end

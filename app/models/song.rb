class Song < ActiveRecord::Base

  #############
  # Attributes
  #############
  FILE_NAME_HASH_SECRET = "CROUOPQNDKUCBVYTQYQLUSKCOMJAQFEWXMEX"
  attr_accessible :show_id, :title, :position, :song_file, :song_collection_ids

  ########################
  # Associations & Scopes
  ########################
  has_many :song_collections_songs, :dependent => :destroy
  has_many :song_collections, :through => :song_collections_songs
  has_many :section_markers
  belongs_to :show
 
  default_scope order :position
  has_attached_file :song_file,
    :url => "/system/:class/:attachment/:id_partition/:style/:hash.:extension",
    :hash_secret => FILE_NAME_HASH_SECRET

  ##############
  # Validations
  ##############
  validates_attachment :song_file, :presence => true,
    :content_type => {:content_type => ['application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3']}
  validates_presence_of :show, :title, :position
  validate :require_at_least_one_song_collection

  ############
  # Callbacks
  ############
  before_validation :populate_song_collection, :populate_position
  before_save :check_file_dirty
  after_save :set_duration

  protected

  def check_file_dirty
    if song_file.dirty?
      Rails.logger.info "* * * IT IS DIRTY * * *"
    else
      Rails.logger.info "* * * NOT DIRTY * * *"
    end
    true
  end

  def set_duration
    unless self.duration # this won't record the correct duration if we're uploading a new file
      Mp3Info.open song_file.path do |mp3|
        self.duration = (mp3.length * 1000).round
        save
      end
    end
  end

  def populate_song_collection
    p 'do we need to populate...'
    if self.song_collections.empty?
      p 'we do!'
      sc = SongCollection.where("lower(title) = ?", self.title.downcase)
      if sc
        p 'populating!'
        self.song_collections << sc
      else
        p 'not populating...'
      end
    end
  end

  def populate_position
    unless self.position
      self.position = Song.where(:show_id => show.id).last.position + 1
    end
  end

  def require_at_least_one_song_collection
    errors.add(:song_collections, "Please add at least one song collection") if song_collections.empty?
  end
end

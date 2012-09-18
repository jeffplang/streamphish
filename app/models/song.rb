class Song < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :show_id, :title, :position, :song_file, :song_collection_id

  has_many :section_markers
  belongs_to :show
  belongs_to :song_collection

  has_attached_file :song_file

  validates_attachment :song_file, :presence => true,
    :content_type => {:content_type => ['application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3']}

  validates_presence_of :show, :title, :position, :song_collection

  before_save :check_file_dirty

  after_save :set_duration

  default_scope order(:position)

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
end

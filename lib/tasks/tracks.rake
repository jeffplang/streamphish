namespace :tracks do

  #########################################################
  # This task sets default ID3 tags on all tracks
  desc "Set default ID3 tags on all Tracks' song_files"
  task :save_default_id3 => :environment do
    tracks = Track.all
    tracks.each_with_index do |track, i|
      p "#{i+1} of #{tracks.size} (#{track.title} - id #{track.id})"
      track.save_default_id3_tags
    end
  end
  
end

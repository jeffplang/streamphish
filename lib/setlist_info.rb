require 'readline'
require_relative '../config/environment'
require_relative 'pnet'

class SetlistInfo

  PNET_API_KEY = '448345A7B7688DDE43D0'

  def initialize(show) # date should be in the form "2/28/1993"
    @pnet  = PNet.new PNET_API_KEY
    @show  = show #Show.find_by_show_date(date)
    @sets  = []
    puts "TRYING: #{@show.show_date.strftime("%-m/%-d/%Y")}"
    @data  = @pnet.shows_setlists_get('showdate' => format_date(@show.show_date.strftime("%-m/%-d/%Y")))[0];

    @used_track_ids = [-1]

    puts ''
    puts @show.show_date.strftime('%m/%d/%Y') + " - " + @show.location
    puts ''

    # Loop through sets from Phish.net API
    Nokogiri::HTML(@data["setlistdata"]).css('p.pnetset').each_with_index do |set, set_idx|
      # Set the set's position and title
      set_attrs = { :show_id => @show.id, :position => set_idx + 1, :title => set.css('span.pnetsetlabel')[0].content.chomp(':'), :tracks => [] }

      # Loop through the songs in the set
      set.css('a').each do |song|
        song_title = song.content
        track = Track.where(:show_id => @show.id).where('id NOT IN (?)', @used_track_ids).where('title LIKE ?', "%#{song_title}%").order(:position).first
        if track
          @used_track_ids << track.id
          set_attrs[:tracks] << track
        # Handle case of '2001' in PT database but 'Also Sprach Zarathustra' from P.Net API
        elsif song_title == 'Also Sprach Zarathustra'
          track = Track.where(:show_id => @show.id).where('id NOT IN (?)', @used_track_ids).where('title LIKE ?', "%2001%").order(:position).first
          if track
            @used_track_ids << track.id
            set_attrs[:tracks] << track
          end
        end
      end

      # Add set_attrs to @sets if the set contains some tracks
      unless set_attrs[:tracks].empty?
        @sets << set_attrs
      end
    end

    # Check for show tracks that haven't been assigned to a set
    @unassigned_tracks = Track.where(:show_id => @show.id).where('id NOT IN (?)', @used_track_ids)

    print_sets

    # Save if they're all assigned
    if @unassigned_tracks.empty?
      puts "NO UNASSIGNED TRACKS!"
      puts ''
      save_sets
    else
      while line = ::Readline.readline("\n#cls> ", true) do
        if line.to_i > 0
          edit_track(line.to_i - 1)
        elsif line == 'c'
          puts "Go to Create Soundcheck Set mode!"
          create_soundcheck_set
        elsif line == 'l'
          puts ""
          print_sets
        elsif line == 's'
          puts ""
          save_sets
          break
        end
      end
    end
  end

  def edit_track(u_t_idx)
    track = @unassigned_tracks[u_t_idx]
    while line = ::Readline.readline('Enter position of assigned set (# >= 1)> ', true) do
      set = @sets.find{ |set| set[:position] == line.to_i }
      if set
        puts 'Adding track to set'
        set[:tracks] << track
        @unassigned_tracks.delete_at(u_t_idx)
        break
      end
    end
  end

  private

  def create_soundcheck_set
    set = { :show_id => @show.id, :position => 1, :title => "Soundcheck", :tracks => [] }
    @sets.each{ |set| set[:position] += 1 }
    @sets.unshift(set)
  end

  def print_sets
    @sets.each do |set_attrs|
      puts "#{set_attrs[:position]}.) #{set_attrs[:title]} :: "
      puts set_attrs[:tracks].sort{|t1,t2| t1.position <=> t2.position}.map{|t| "  #{t.position}.) #{t.title}" }.join("\n")
      puts ''
    end
    unless @unassigned_tracks.empty?
      puts "UNASSIGNED TRACKS: "
      puts @unassigned_tracks.each_with_index.map{|t,i| "#{i + 1}.) (#{t.position}) #{t.title}"}.join("\n")
      puts ''
    end
  end

  def save_sets
    puts 'Saving...'
    @sets.each do |set_attrs|
      save_set(set_attrs)
    end
  end

  def save_set(set_attrs)
    tracks = set_attrs.delete(:tracks)
    return if tracks.empty?
    cs = ConcertSet.create(set_attrs)
    cs.tracks << tracks
  end

  def format_date(date)
    month, day, year = date.split('/')
    "%d-%02d-%02d" % [year, month, day]
  end

end

if __FILE__ == $0
  ARGV.each do |show_date|
    show = Show.find_by_show_date(show_date)
    SetlistInfo.new(show) if show
  end
  # Show.for_year(ARGV[0]).each do |show|
  #   SetlistInfo.new(show)
  # end
end
require_relative '../config/environment'
require_relative 'show_info'
require_relative 'filename_matcher'

module ShowImporter

  class ShowImporter
    attr_reader :show, :fm, :songs

    def initialize(date)
      puts "Fetching show info..."
      @show_info = ShowInfo.new date
      puts "Analyzing filenames..."
      @fm    = FilenameMatcher.new date

      @show = Show.where(:show_date => Date.strptime(date, '%m/%d/%Y')).first
      @show ||= Show.new(:location => @show_info.location, :show_date => Date.strptime(date, '%m/%d/%Y'))

      # SWITCHOVA TIME 
      # @show = Show.where(:show_date => Date.strptime(date, '%Y-%m-%d')).first
      # @show ||= Show.new(:location => @show_info.location, :show_date => Date.strptime(date, '%Y-%m-%d'))

      @songs = []
      populate_songs
    end

    def pp_list
      @songs.each do |song|
        puts song
      end
    end

    def combine_up(pos)
      assimilating = get_song(pos)
      receiving = get_song(pos - 1)

      return if assimilating.nil? || receiving.nil?

      receiving.merge_song(assimilating)
      @songs.delete assimilating

      @songs.each { |song| song.decr_pos if song.pos > pos }
    end

    def get_song(pos)
      @songs.find{|s| s.pos == pos}
    end

    def save
      @show.save
      @songs.each do |s|
        if s.valid?
          s.show = @show
          s.file = File.new("#{@fm.s_dir}/#{s.filename}")
          s.save
        end
      end
    end

    private

    def populate_songs
      matches = @fm.matches.dup
      @show_info.songs.each do |pos, song|
        fn_match = matches.find{ |k,v| !v.nil? && v.title == song }
        if fn_match
          @songs << SongProxy.new(pos, song, fn_match[0], fn_match[1])
          matches.delete(fn_match[0])
        else
          @songs << SongProxy.new(pos, song)
        end
      end
    end
  end


  class SongProxy
    attr_accessor :filename

    def initialize(pos=nil, title=nil, filename=nil, song_collection=nil)
      @_song = ::Song.new(:position => pos, :title => title)

      @_song.song_collections << song_collection unless song_collection.nil?

      @filename = filename
    end

    def valid?
      !@filename.nil? && !@_song.title.nil? && !@_song.position.nil? && !@_song.song_collections.empty?
    end

    def to_s
      (!valid? ? '* ' : '  ') + 
      ("%2d.) %-30.30s     %-30.30s     " % [pos, @_song.title, @filename]) + 
      @_song.song_collections.map{ |sc| "SC: %-3d %-20.20s" % [sc.id, sc.title] }.join('   ')
    end

    def pos
      @_song.position
    end

    def title
      @_song.title
    end

    def decr_pos
      @_song.position -= 1
    end

    def song_collections
      @_song.song_collections
    end

    def show=(show)
      @_song.show_id = show.id
    end

    def file=(file)
      @_song.song_file = file
    end

    def merge_song(song)
      @_song.title += " > #{song.title}"
      @_song.song_collections << song.song_collections
      @filename = song.filename if @filename.nil? && !song.filename.nil?
    end

    def save
      @_song.save
    end
  end


  class Cli
    def initialize
      require 'readline'

      @si = ShowImporter.new(ARGV[0])
      main_menu

      puts "\nPick a position to edit: "
      while line = Readline.readline('> ', true)
        pos = line.to_i
        if pos > 0
          edit_for_pos(pos)
        elsif line == 'f'
          print_filenames
        elsif line == 'l'
          main_menu
        elsif line == 's'
          puts "Saving..."
          @si.save
        end
      end
    end

    def main_menu
      puts "\n#{@si.show} #{' ::SBD::' if @si.}\n\n"
      @si.pp_list
    end

    def print_filenames
      filenames = @si.fm.matches.keys

      filenames.each_with_index do |fn, i| 
        puts "%2d.) %s" % [i + 1, fn]
      end
      filenames
    end

    def edit_for_pos(pos)
      help_str = "Combine (u)p, Choose (s)ong collection, Choose (f)ile, Toggle s(b)d"
      puts "#{@si.get_song(pos)}"
      puts help_str

      while line = Readline.readline('usf?> ', false)

        if line == 'u'
          puts "Combining up (#{pos}) #{@si.get_song(pos).title} into (#{pos - 1}) #{@si.get_song(pos - 1).title}"
          @si.combine_up(pos)
          break
        elsif line == 's'
          update_sc_for_pos(pos)
        elsif line == 'f'
          update_file_for_pos(pos)
        elsif line == 'b'
          toggle_sbd
          puts "Is SBD: " + @si.show.sbd ? 'YES' : 'NO'
        elsif line == '?'
          puts "#{@si.get_song(pos)}"
          puts help_str
        end

      end
    end

    def update_sc_for_pos(pos)
      puts "Enter exact song title:"
      while line = Readline.readline('?> ', true)
        if match = @si.fm.find_match(line, :exact => true)
          puts "Found \"#{match.title}\".  Adding SongCollection."
          @si.get_song(pos).song_collections << match
        end
        break
      end
    end

    def toggle_sbd
      @si.show.sbd = !@si.show.sbd
    end

    def update_file_for_pos(pos)
      puts "Choose a file:"
      filenames = print_filenames

      while line = Readline.readline("1-#{filenames.length} > ")
        choice = line.to_i
        if choice > 0
          new_filename = filenames[choice - 1]
          puts "Updating filename to '#{new_filename}'"
          @si.get_song(pos).filename = new_filename
          break
        end
      end
    end
  end
end



if __FILE__ == $0
  if ARGV.length < 1
    puts "Need date"
  else
    ShowImporter::Cli.new
  end
end
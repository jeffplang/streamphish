require_relative '../config/environment'
require_relative 'show_info'
require_relative 'filename_matcher'

module ShowImporter

  class ShowImporter
    attr_reader :show, :fm, :songs, :sets

    def initialize(date)
      puts "Fetching show info..."
      @show_info = ShowInfo.new date
      puts "Analyzing filenames..."
      @fm    = FilenameMatcher.new date

      @show = Show.where(:show_date => Date.strptime(date, '%m/%d/%Y')).first || \
              Show.new(:location => @show_info.location, :show_date => Date.strptime(date, '%m/%d/%Y'))

      @songs = []
      @sets = []
      populate_sets
    end

    def pp_list
      @sets.each do |set|
        puts "#{set.title} ::"
        set.tracks.each do |track|
          puts (!track.valid? ? '* ' : '  ') + 
               ("%2d.) %-30.30s     %-30.30s     " % [track.position, track.title, track.song_file.queued_for_write[:original].original_filename]) + 
               track.songs.map{ |sc| "SC: %-3d %-20.20s" % [sc.id, sc.title] }.join('   ')
        end
      end
    end

    def combine_up(pos)
      assimilating = get_song(pos)
      receiving = get_song(pos - 1)

      return if assimilating.nil? || receiving.nil?

      receiving.title += " > #{assimilating.title}"
      receiving.songs << assimilating.songs.reject{ |s| receiving.songs.include?(s) }
      
      delete pos
    end

    def delete(pos)
      @sets.each do |set|
        t = set.tracks.find{ |t| t.position == pos }

        set.tracks.destroy(t) unless t.nil?
      end

      @sets.each do |set| 
        set.tracks.each do |t| 
          t.decrement(:position) if t.position > pos
        end
      end
    end

    def get_song(pos)
      found_song = nil
      @sets.each do |set|
        found_song = set.tracks.find{|t| t.position == pos}
        break if found_song
      end
      found_song
    end

    def save
      @show.save
      @sets.each(&:save)
    end

    private

    def populate_sets
      matches = @fm.matches.dup
      @show_info.sets.each_with_index do |set, idx|
        cset   = ConcertSet.new(:title => set[0], :position => idx + 1, :show => @show)
        songs = set[1]

        songs.each do |pos, song|
          fn_match = matches.find{ |k,v| !v.nil? && v.title == song }
          if fn_match
            track = Track.new(:title => song, :position => pos, :song_file => File.new("#{@fm.s_dir}/#{fn_match[0]}"), :show => @show)
            cset.tracks << track
          end
        end

        @sets << cset
      end
    end
  end


  class Cli
    def initialize
      require 'readline'

      ARGV.each do |date|
        @si = ShowImporter.new(date)
        main_menu

        # puts "\nPick a position to edit, Toggle S(b)D, Show (f)ilenames, Show song (l)ist, (i)nsert new, (d)elete song, (s)ave: "
        puts "\n(s)ave: "
        while line = Readline.readline('#lis> ', true)
          pos = line.to_i
          if pos > 0
            edit_for_pos(pos)
          elsif line == 'l'
            main_menu
          elsif line == 'i'
            edit_source_info
          elsif line == 's'
            puts "Saving..."
            @si.save
            break
          end
        end
      end
    end

    def main_menu
      puts "\n#{@si.show} #{' ::SBD::' if @si.show.sbd}\n\n"
      puts "#{@si.show.source_info}\n\n" unless @si.show.source_info.blank?
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
      # help_str = "Combine (u)p, Choose (s)ong collection, Choose (f)ile, Change (t)itle"
      help_str = "Combine (u)p, (d)elete, Choose (f)ile"
      puts @si.get_song(pos)
      puts help_str

      while line = Readline.readline('udf> ', false)

        if line == 'u'
          puts "Combining up (#{pos}) #{@si.get_song(pos).title} into (#{pos - 1}) #{@si.get_song(pos - 1).title}"
          @si.combine_up(pos)
          break
        end
        if line == 'd'
          @si.delete(pos)
          break
        end
        if line == 'f'
          update_file_for_pos(pos)
        end

      end
      puts
    end

    def edit_source_info
      puts "Paste source info, then type END on next line"
      $/ = "END"
      source_info = STDIN.gets.gsub(/\nEND$/, '')
      @si.show.source_info = source_info
    end

    def insert_new_song
      puts "Before song #:"
      while line = Readline.readline('> ', true)
        @si.insert_before(line.to_i)
        break
      end
    end

    def delete_song
      puts "Delete song #:"
      while line = Readline.readline('> ', true)
        @si.delete(line.to_i)
        break
      end
    end

    def update_sc_for_pos(pos)
      puts "Enter exact song title:"
      while line = Readline.readline('?> ', true)
        if match = @si.fm.find_match(line, :exact => true)
          puts "Found \"#{match.title}\".  Adding Song."
          @si.get_song(pos).songs << match
        end
        break
      end
      puts
    end

    def update_title_for_pos(pos)
      puts "Enter new title:"
      while line = Readline.readline('> ', true)
        @si.get_song(pos).title = line
        break
      end
      puts
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
          @si.get_song(pos).song_file = File.new("#{@si.fm.s_dir}/#{new_filename}")
          break
        end
      end
      puts
    end
  end
end


Track.send(:define_method, 'to_s') do
  (!valid? ? '* ' : '  ') + 
  ("%2d.) %-30.30s     %-30.30s     " % [position, title, song_file.queued_for_write[:original].original_filename]) + 
  songs.map{ |sc| "SC: %-3d %-20.20s" % [sc.id, sc.title] }.join('   ')
end


if __FILE__ == $0
  if ARGV.length < 1
    puts "Need date"
  else
    ShowImporter::Cli.new
  end
end

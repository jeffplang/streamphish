require 'open-uri'
require 'nokogiri'
require_relative 'pnet'

class ShowInfo
  PNET_API_KEY = '448345A7B7688DDE43D0'

  attr_reader :songs, :sets, :pnet, :data

  def initialize(date) # date should be in the form "2/28/1993"
    @pnet  = PNet.new PNET_API_KEY
    @songs = {}
    @sets  = {}
    @data  = @pnet.shows_setlists_get('showdate' => format_date(date))[0];

    songs_idx = 0
    Nokogiri::HTML(@data["setlistdata"]).css('p.pnetset').each do |set|
      set_title = set.css('span.pnetsetlabel')[0].content.chomp(':')
      songs = {}
      set.css('a').map(&:content).each_with_index do |song|
        songs[songs_idx + 1] = song
        songs_idx += 1
      end
      @sets[set_title] = songs
    end

    # songs  = Nokogiri::HTML(@data["setlistdata"]).css('p.pnetset > a').map(&:content)
    # raise "Invalid date" if songs.empty? 
    # # Sometimes songs will be empty, returned from phish.net API.  Ex. 1993-08-21
    # songs.each_with_index do |song, i|
    #   @songs[i + 1] = song
    # end
  end

  def [](pos)
    @songs[pos]
  end

  def location
    last_part = @data['state'].blank? ? @data['country'] : @data['state']
    "#{@data['venue']} - #{@data['city']}, #{last_part}"
  end

  private

  def format_date(date)
    puts "DATE: #{date}"
    month, day, year = date.split('/')
    "%d-%02d-%02d" % [year, month, day]
  end

end
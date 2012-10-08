require 'open-uri'
require 'nokogiri'
require_relative 'pnet'

class ShowInfo
  PNET_API_KEY = '448345A7B7688DDE43D0'

  attr_reader :songs, :pnet

  def initialize(date) # date should be in the form "2/28/1993"
    @pnet  = PNet.new PNET_API_KEY
    @songs = {}
    @data  = @pnet.shows_setlists_get('showdate' => format_date(date))[0];
    songs  = Nokogiri::HTML(@data["setlistdata"]).css('p.pnetset > a').map(&:content)

    raise "Invalid date" if songs.empty?

    # Sometimes songs will be empty, returned from phish.net API.  Ex. 1993-08-21
    songs.each_with_index do |song, i|
      @songs[i + 1] = song
    end
  end

  def [](pos)
    @songs[pos]
  end

  def location
    "#{@data['venue']} - #{@data['city']}, #{@data['state']}"
  end

  private

  def format_date(date)
    # ATTN: TEMP DISABLED UNTIL WE DONE WIT MAY
    # 
    # month, day, year = date.split('/')
    # "%d-%02d-%02d" % [year, month, day]
    date
  end

end
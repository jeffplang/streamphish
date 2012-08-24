task :populate_song_collections => :environment do 
  require 'open-uri'

  SONG_TITLES_URL = 'http://phish.net/song/'

  doc = Nokogiri::HTML(open(SONG_TITLES_URL))
  song_table = doc.at_css('table.tablesorter')

  song_table.css('td:first-child').each do |cell| 
    p "Adding SongCollection for #{cell.text}"
    SongCollection.create(:title => cell.text)
  end
end
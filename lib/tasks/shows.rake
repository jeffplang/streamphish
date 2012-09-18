namespace :shows do 
  task :get_shows_info => :environment do
    require 'open-uri'

    SHOW_LIST_URL = 'https://spreadsheets.google.com/spreadsheet/pub?key=0AjeIQ6qQvexzcDhXS2twUC1US3BPMVZuUWdjZmY2RVE&gid=15'
    idxs = {
      date: 1, 
      sbd: 2, 
      venue: 4,
      city: 5,
      state: 6,
      link: 7
    }

    doc         = Nokogiri::HTML(open(SHOW_LIST_URL))
    songTable   = doc.at_css('table#tblMain')
    firstRowIdx = 7

    rows = doc.css('tr')[firstRowIdx..-1]

    rows.each do |row|
      fields = row.children
      unless fields[idxs[:date]].content.blank?
        p "#{fields[idxs[:date]].content} -- #{fields[idxs[:venue]].content} - #{fields[idxs[:city]].content}, #{fields[idxs[:state]].content}"
      end
    end
  end

  task :get_songs => :environment do
    require 'pnet'
    api_key = '448345A7B7688DDE43D0'

    pnet = PNet.new api_key
    setlist = pnet.shows_setlists_get('showdate' => ENV['date'])[0]; 
    songs = Nokogiri::HTML(setlist["setlistdata"]).css('p.pnetset > a').map(&:content)

    songs.each_with_index do |song, i|
      p "#{i + 1}. #{song}"
    end
  end
end
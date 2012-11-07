class SandboxesController < ApplicationController
  require 'nokogiri'
  require 'open-uri'
  
  # Scrape phish.net/venues
  def parse_venues
    
    num_venues_created = 0
    num_venues_updated = 0
    num_shows_found = 0
    missing_shows = []
    
    # Pull in basic details of all venues
    doc = Nokogiri::HTML(open("http://www.phish.net/venues"))
    rows = doc.css('table tr')
    venue_list = rows.collect do |row|
      detail = {}
      [
        [:name, 'td[1]/a/text()'],
        [:url, 'td[1]/a/@href'],
        [:city, 'td[2]/text()'],
        [:state, 'td[3]/text()'],
        [:country, 'td[4]/text()'],
        [:show_count, 'td[5]/text()'],
        [:first_date, 'td[6]/a/text()'],
        [:last_date, 'td[7]/a/text()']
      ].each do |name, xpath|
        detail[name] = Iconv.conv('utf-8', 'latin1', row.at_xpath(xpath).to_s.strip)
      end
      detail
    end
    
    # Create/update venue records
    venue_list.each do |v|
      unless v[:name].empty?
        venue = Venue.where("name = ?", v[:name]).first
        venue_attributes = v.reject{|k,v| !Venue.new.attributes.keys.member?(k.to_s)}
        if venue
          venue.update_attributes(venue_attributes)
          num_venues_updated += 1
        else
          venue = Venue.new(venue_attributes)
          venue.save
          num_venues_created += 1
        end
      end
    end
    venues_report = "VENUES: " + num_venues_updated.to_s + " updated, " + num_venues_created.to_s + " created"
    # raise venues_report.inspect
    
    # Get list of shows for each venue
    # WARNING: This cannot handle multiple shows on a single day...only one will have the correct venue association
    venue_list.each_with_index do |v, i|
      unless v[:url].empty? or v[:name].empty?
        venue = Venue.where("name = ?", v[:name]).first
        rows = Nokogiri::HTML(open("http://www.phish.net" + v[:url])).css('#mainContent ul li')
        date_list = rows.collect { |row| row.at_xpath('a[1]/text()').to_s.strip }
        date_list.each do |date|
          show = Show.where("show_date = ?", date).first
          if show
            num_shows_found += 1
            show.venue = venue
            show.save
          else
            missing_shows << date
          end
        end
        
      end
    end
    raise missing_shows.inspect
  end
  
end
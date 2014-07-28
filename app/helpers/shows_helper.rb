module ShowsHelper
  def randCSSLeft(prevLeft)
    return 0 if prevLeft <= 0
    prevLeft + rand(35..100)
  end

  def title
    "#{date_and_location} - PhishTracks"
  end

  def date_and_location
    "#{@show.show_date.strftime('%m/%d/%Y')} #{@show.location}"
  end

  def meta_description
    date_and_location if @song
  end
end

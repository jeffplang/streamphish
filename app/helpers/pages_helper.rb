module PagesHelper
  def translucent_if_empty(year)
    year_empty?(year) ? 'empty' : ''
  end

  def year_empty?(year)
    Show.for_year(year).count.zero?
  end
end

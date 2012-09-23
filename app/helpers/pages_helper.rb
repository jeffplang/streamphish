module PagesHelper
  def translucent_if_empty(year)
    Show.for_year(year).count.zero? ? 'empty' : ''
  end
end

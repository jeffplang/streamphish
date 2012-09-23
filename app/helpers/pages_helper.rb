module PagesHelper
  def hide_if_empty(year)
    Show.for_year(year).count.zero? ? 'visibility: hidden' : ''
  end
end

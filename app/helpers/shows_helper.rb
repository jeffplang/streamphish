module ShowsHelper
  def randCSSLeft(prevLeft)
    return 0 if prevLeft <= 0
    prevLeft + rand(35..100)
  end
  
  def download_show_button(show)
    link_to "<i class=\"icon-download icon-white\"></i> Download Show".html_safe, "", :class =>
"btn btn-warning download-album", :data => { :request_url => "#{request_download_show_path(show)}/" }
  end
  
  def download_set_button(show, set)
    link_to "<i class=\"icon-download icon-white\"></i> Download Set".html_safe, "", :class =>
"btn btn-small btn-warning download-album", :data => { :request_url => "#{request_download_show_path(show)}/?set=#{set}" }
  end
  
end
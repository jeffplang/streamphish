module ShowsHelper
  def randCSSLeft(prevLeft)
    return 0 if prevLeft <= 0
    prevLeft + rand(35..100)
  end
  
  def download_show_button(show)
    link_to "<i class=\"icon-download icon-white\"></i> Download Show".html_safe, "", :class =>
"btn btn-warning download-album", :data => { :base_url => "#{show_path(show)}/" }
  end
  
end
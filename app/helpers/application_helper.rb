module ApplicationHelper
  def ms_to_MMSS(ms)
    "%d:%02d" % [ms / 60000, ms % 60000 / 1000]
  end

  def li_tags_for(thing)
    show = thing.is_a?(Show) ? thing : thing.show
    %!#{'<span class="tag">sbd</span>' if show.sbd}#{'<span class="tag">remastered</span>' if show.remastered}!.html_safe
  end

  def back_link_for(thing)
    if thing.is_a?(Show)
      if Date.new(1983).beginning_of_year < thing.show_date && thing.show_date < Date.new(1987).end_of_year
        text, href = '83-87', shows_path(:year => '83-87')
      else
        text, href = thing.show_date.year, shows_path(:year => thing.show_date.year)
      end
    elsif thing.is_a?(Song)
      text, href = "Songs", songs_path
    else
      text, href = "Home", root_path
    end

    link_to "&#8592; #{text}".html_safe, href, :class => "link_back"
  end

  def random_css_color
    "#%02x%02x%02x" % [rand(256), rand(256), rand(256)]
  end

  def random_bg_and_text_colors
    bg = Color::RGB.new(rand(256), rand(256), rand(256))
    palette = Color::Palette::MonoContrast.new(bg)
    
    [palette.background[-2].html, palette.foreground[-5].html]
  end

  def lighter_hover_for(color)
    Color::RGB.from_html(color).lighten_by(90).html
  end

  def lighter_hover_inline_js(bg)
    ("onMouseOver=\"this.style.background='#{lighter_hover_for bg}';" + \
                   "this.style.border='#{lighter_hover_for bg}!important';\" " + \
     "onMouseOut=\"this.style.background='#{bg}';" + \
                  "this.style.border='#{bg}!important';\"").html_safe
  end

  def track_data_attribs(track, list_type)
    (%!data-song-uri="#{track.song_file.url}" ! + \
     %!data-duration="#{track.duration}" ! + \
     %!data-title="#{track.title}"! + \
     (list_type == :song ? %! data-show="#{track.show.to_s}"! : '')).html_safe
  end
end

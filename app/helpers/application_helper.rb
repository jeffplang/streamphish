module ApplicationHelper
  def ms_to_MMSS(ms)
    "%d:%02d" % [ms / 60000, ms % 60000 / 1000]
  end

  def random_css_color
    "#%02x%02x%02x" % [rand(256), rand(256), rand(256)]
  end
end

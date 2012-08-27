module ApplicationHelper
  def ms_to_MMSS(ms)
    "%d:%02d" % [ms / 60000, ms % 60000 / 1000]
  end
end

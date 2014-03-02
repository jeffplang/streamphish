class ApplicationController < ActionController::Base
  protect_from_forgery

  before_action :get_years, unless: Proc.new{ |c| c.class < ApiController }

  protected

  def get_years
    @years ||= (['83-87'] + (1988..2013).to_a - [2001, 2005, 2006, 2007, 2008]).map do |year|
      bg = Color::RGB.new rand(256), rand(256), rand(256)
      palette = Color::Palette::MonoContrast.new bg

      { year: year, bg: palette.background[-2].html, fg: palette.foreground[-5].html }
    end
  end
end

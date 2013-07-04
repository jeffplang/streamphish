class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def get_years
    @years ||= ['83-87'] + (1988..2013).to_a - [2001, 2005, 2006, 2007, 2008]
  end
end

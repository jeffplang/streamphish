class ApplicationController < ActionController::Base
  protect_from_forgery

  protected

  def get_years
    @years ||= ['83-87'] + (1988..2012).to_a
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery

  layout Proc.new { |controller| controller.request.xhr? ? nil : 'application' }

  protected

  def get_years
    @years ||= ['83-87'] + (1988..2012).to_a
  end

end

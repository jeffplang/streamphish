class SessionsController < Devise::SessionsController
  layout 'soundcloud_sync'

  private

  def after_sign_in_path_for(resource)
    super
  end
end
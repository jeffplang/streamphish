Streamphish::Application.routes.draw do
  devise_for :users

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :shows
  resources :songs

  match "/years" => "pages#years"
  
  # SANDBOX TEST STUFF
  match "/download" => "sandboxes#download"

  root :to => 'pages#index'

end

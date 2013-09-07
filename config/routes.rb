Streamphish::Application.routes.draw do
  devise_for :users

  resources :shows
  resources :songs

  get "/years" => "pages#years"
  
  # SANDBOX TEST STUFF
  get "/download" => "sandboxes#download"

  root :to => 'pages#index'

end

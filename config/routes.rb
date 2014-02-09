Streamphish::Application.routes.draw do
  devise_for :users

  resources :shows
  resources :songs

  get "/years" => "pages#years"

  root :to => 'pages#index'

end

Streamphish::Application.routes.draw do
  devise_for :users
  namespace :api do
    namespace :v1 do
      resources :shows
      resources :songs
    end
  end

  resources :shows, only: [:index, :show]
  resources :songs, only: [:index, :show]

  get "/years" => "pages#years"

  root :to => 'pages#index'

end

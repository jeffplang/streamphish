Streamphish::Application.routes.draw do
  devise_for :users
  namespace :api do
    namespace :v1 do
      resources :shows
      resources :songs
    end
  end

  get '/shows/:id/:song', to: 'shows#show', constraints: { id: /\d{4}-\d{1,2}-\d{1,2}/ }

  resources :shows, only: [:index, :show]
  resources :songs, only: [:index, :show]

  root :to => 'pages#index'

end

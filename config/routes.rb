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

  resources :sitemaps, only: [:index, :show] do
    collection do
      get :sections
      get :songs
      get 'shows/:date', to: :show_by_date,  constraints: { date: /\d{4}-\d{1,2}-\d{1,2}/ }, as: :show_by_date
      get 'shows/:year', to: :shows_by_year, constraints: { year: /\d{4}|83\-87/ },          as: :shows_by_year
    end
  end

  root :to => 'pages#index'

end

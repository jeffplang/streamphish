Streamphish::Application.routes.draw do
  devise_for :users

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  resources :shows do
    member do
      get 'download'
    end
  end
  resources :songs
  resources :tracks do
    member do
      get 'download'
    end
  end

  get "/years" => "pages#years"
  get "/venues" => "pages#venues"
  get "/tours" => "pages#tours"
  get "/cities" => "pages#cities"
  get "/states" => "pages#states"
  get "/countries" => "pages#countries"

  root :to => 'pages#index'

end

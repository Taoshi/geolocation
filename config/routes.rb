# frozen_string_literal: true

Rails.application.routes.draw do
  root to: redirect('/docs')

  mount Rswag::Ui::Engine => '/docs'
  mount Rswag::Api::Engine => '/api-docs'

  namespace :api do
    namespace :v1 do
      resources :geolocations, only: %i[create]
      delete 'geolocations', to: 'geolocations#destroy'
      get 'geolocations', to: 'geolocations#show'
    end
  end
end

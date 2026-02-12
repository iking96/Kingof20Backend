# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper do
    # No need to register client application
    skip_controllers :applications, :authorized_applications
  end

  scope module: :api, defaults: { format: :json }, path: 'api' do
    scope module: :v1, constraints: ApiVersion.new(version: 1, default: true), path: 'v1' do
      devise_for :users, controllers: {
        registrations: 'api/v1/users/registrations',
      }, skip: [:sessions, :password]

      resources :games do
        resources :moves, only: [:index], to: 'games#moves'
      end
      post 'moves/ai_move', to: 'moves#ai_move'
      resources :moves
      resources :users, only: [:show], param: :username
    end
  end

  mount ActionCable.server => '/cable'

  # Forward all requests to StaticController#index with
  # some formatting requirements
  get '*page', to: 'static#index', constraints: ->(req) do
    !req.xhr? && req.format.html?
  end

  # Forward root to StaticController#index
  root 'static#index'
end

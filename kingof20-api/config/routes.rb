# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper do
    # No need to register client application
    skip_controllers :applications, :authorized_applications
  end

  scope module: :api, defaults: { format: :json }, path: 'api' do
    scope module: :v1, constraints: ApiVersion.new(version: 1, default: true) do
      devise_for :users, controllers: {
        registrations: 'api/v1/users/registrations',
      }, skip: [:sessions, :password]

      resources :games
      resources :moves
    end
  end
end

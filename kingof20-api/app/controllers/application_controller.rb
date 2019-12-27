# frozen_string_literal: true

class ApplicationController < ActionController::API
  include Response

  # Devise code
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Doorkeeprt code
  before_action :doorkeeper_authorize!

  respond_to :json

  protected

  # Devise methods
  # Authentication key(:username) and password field will be added automatically by devise.
  def configure_permitted_parameters
    added_attrs = [:email, :username]
    devise_parameter_sanitizer.permit(:sign_up, keys: added_attrs)
    devise_parameter_sanitizer.permit(:account_update, keys: added_attrs)
  end

  # Doorkeeper methods
  def current_resource_owner
    User.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end

  include Error::ErrorHandler
end

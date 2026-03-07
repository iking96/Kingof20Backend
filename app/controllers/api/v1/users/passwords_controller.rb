# frozen_string_literal: true

class Api::V1::Users::PasswordsController < Devise::PasswordsController
  skip_before_action :doorkeeper_authorize!
  respond_to :json

  # POST /api/v1/users/password
  # Request password reset email
  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)

    if successfully_sent?(resource)
      render json: { message: 'Password reset instructions sent to your email' }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # PUT /api/v1/users/password
  # Reset password with token
  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      render json: { message: 'Password has been reset successfully' }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def resource_params
    params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
  end
end

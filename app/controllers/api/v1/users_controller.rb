# frozen_string_literal: true

module Api
  module V1
    class UsersController < ApplicationController
      skip_before_action :doorkeeper_authorize!, only: [:show]

      def show
        user = User.find_by!(username: params[:username])
        stats = UserLogic::StatsCalculator.new(user).calculate

        json_response(
          user: {
            id: user.id,
            username: user.username,
            created_at: user.created_at,
            stats: stats,
          }
        )
      rescue ActiveRecord::RecordNotFound
        json_response({ error: 'User not found' }, :not_found)
      end

      def me
        user = current_user
        stats = UserLogic::StatsCalculator.new(user).calculate

        json_response(
          user: {
            id: user.id,
            username: user.username,
            email: user.email,
            created_at: user.created_at,
            stats: stats,
          }
        )
      end

      def update_me
        user = current_user

        if user.update(user_params)
          json_response(
            user: {
              id: user.id,
              username: user.username,
              email: user.email,
            },
            message: 'Profile updated successfully'
          )
        else
          json_response({ errors: user.errors.full_messages }, :unprocessable_entity)
        end
      end

      private

      def user_params
        params.require(:user).permit(:email)
      end
    end
  end
end

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
    end
  end
end

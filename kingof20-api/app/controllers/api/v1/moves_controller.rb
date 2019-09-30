# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApplicationController
      before_action :index_params, only: [:index]

      def index
        @games = GameLogic::MoveManager.get_user_moves_with_params(
          user: current_resource_owner,
          params: @permitted_params
        )

        json_response(@games)
      end
    end
  end
end

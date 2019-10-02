# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApplicationController
      before_action :index_params, only: [:index]
      before_action :create_params, only: [:create]

      def index
        @moves = GameLogic::MoveManager.get_user_moves_with_params(
          user: current_resource_owner,
          params: @permitted_params
        )

        json_response(@moves)
      end

      def create
        @move = GameLogic::MoveManager.create_move_and_update_game(
          game: GameLogic::GameManager.get_user_game(
            game_id: @permitted_params[:game_info][:id],
            user: current_resource_owner,
          ),
          user: current_resource_owner,
        )

        json_response(@move)
      end

      def index_params
        @permitted_params = params.permit(GameLogic::GameManager::USER_MOVE_QUERY_PARAMS).to_h
      end

      def create_params
        @permitted_params = params.require(:game_info).permit(:id).to_h
      end
    end
  end
end

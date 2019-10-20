# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApplicationController
      before_action :index_params, only: [:index]
      before_action :create_params, only: [:create]

      def index
        @moves = PlayLogic::MoveManager.get_user_moves_with_params(
          user: current_resource_owner,
          params: @permitted_params
        )

        json_response(@moves)
      end

      def create
        @move = PlayLogic::MoveManager.create_move_and_update_game(
          move_info: @permitted_params[:move_info],
        )

        json_response(@move)
      end

      def index_params
        @permitted_params = params.permit(PlayLogic::GameManager::USER_MOVE_QUERY_PARAMS).to_h
      end

      def create_params
        @permitted_params = params.require(:move_info).permit(
          :game_id,
          :row_num,
          :col_num,
          :tile_value,
        ).merge(
          user_id: current_resource_owner.id
        ).to_h
      end
    end
  end
end

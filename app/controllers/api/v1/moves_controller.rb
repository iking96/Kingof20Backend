# frozen_string_literal: true

module Api
  module V1
    class MovesController < ApplicationController
      before_action :index_params, only: [:index]
      before_action :create_params, only: [:create]

      def index
        @moves = PlayLogic::MoveLogic::MoveManager.get_user_moves_with_params(
          user: current_resource_owner,
          params: @permitted_params
        )

        add_resource_count
        json_response(@moves)
      end

      def show
        @move = PlayLogic::MoveLogic::MoveManager.get_user_move(
          move_id: params[:id],
          user: current_resource_owner,
        )

        json_response(@move)
      end

      def create
        @move = PlayLogic::MoveLogic::MoveManager.create_move_and_update_game(
          user: current_resource_owner,
          move_info: @permitted_params,
        )

        json_response(@move)
      end

      def index_params
        @permitted_params = params.permit(PlayLogic::MoveLogic::MoveManager::MOVE_INDEX_PARAMS).to_h
      end

      def create_params
        @permitted_params = params.require(:move_info).permit(
          :game_id,
          :move_type,
          returned_tiles: [],
          row_num: [],
          col_num: [],
          tile_value: [],
        ).merge(
          user_id: current_resource_owner.id
        ).to_h
      end

      def add_resource_count
        response.set_header('X-total-count', @moves.count)
      end
    end
  end
end

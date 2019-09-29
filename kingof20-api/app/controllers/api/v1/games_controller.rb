# frozen_string_literal: true

module Api
  module V1
    class GamesController < ApplicationController
      before_action :index_params, only: [:index]

      def index
        @games = GameLogic::GameManager.get_user_games_with_params(
          user: current_resource_owner,
          params: @permitted_params
        )

        json_response(@games)
      end

      def show
        @game = GameLogic::GameManager.get_user_game(
          game_id: params[:id],
          user: current_resource_owner,
        )

        json_response(@game)
      end

      def create
        @game = GameLogic::GameManager.create_game_or_enqueue_for_user(
          user: current_resource_owner,
        )

        json_response(@game)
      end

      def destroy
        @game = GameLogic::GameManager.delete_user_game(
          game_id: params[:id],
          user: current_resource_owner,
        )

        json_response(@game)
      end

      def index_params
        @permitted_params = params.permit(GameLogic::GameManager::USER_GAME_QUERY_PARAMS).to_h
      end
    end
  end
end

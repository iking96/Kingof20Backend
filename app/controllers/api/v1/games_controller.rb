# frozen_string_literal: true

module Api
  module V1
    class GamesController < ApplicationController
      before_action :index_params, only: [:index]
      before_action :update_params, only: [:update]

      def index
        @games = PlayLogic::GameLogic::GameManager.get_user_games_with_params(
          user: current_resource_owner,
          params: @permitted_params
        )

        add_resource_count
        json_response(games: @games)
      end

      def show
        @game = PlayLogic::GameLogic::GameManager.get_user_game(
          game_id: params[:id],
          user: current_resource_owner,
        )

        json_response(game: @game)
      end

      def create
        @game = PlayLogic::GameLogic::GameManager.create_game_or_enqueue_for_user(
          user: current_resource_owner,
        )

        json_response(game: @game)
      end

      def update
        @game = PlayLogic::GameLogic::GameManager.update_game(
          game_id: params[:id],
          user: current_resource_owner,
          params: @permitted_params
        )

        json_response(game: @game)
      end

      def destroy
        @game = PlayLogic::GameLogic::GameManager.delete_user_game(
          game_id: params[:id],
          user: current_resource_owner,
        )

        json_response(game: @game)
      end

      def index_params
        @permitted_params = params.permit(PlayLogic::GameLogic::GameManager::GAME_INDEX_PARAMS).to_h
      end

      def update_params
        @permitted_params = params.permit(PlayLogic::GameLogic::GameManager::GAME_UPDATE_PARAMS).to_h
      end

      def add_resource_count
        response.set_header('X-total-count', @games.count)
      end
    end
  end
end

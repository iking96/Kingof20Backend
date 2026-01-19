# frozen_string_literal: true

module Api
  module V1
    class GamesController < ApplicationController
      before_action :index_params, only: [:index]
      before_action :move_params, only: [:moves]
      before_action :update_params, only: [:update]

      def index
        user = current_resource_owner
        @games = PlayLogic::GameLogic::GameManager.get_user_games_with_params(
          user: user,
          params: @permitted_params
        )
        @games.each { |g| g.requesting_user_id = user.id }

        add_resource_count
        json_response(games: @games)
      end

      def moves
        @moves = PlayLogic::MoveLogic::MoveManager.get_game_moves(
          game_id: @permitted_params[:game_id],
        )

        json_response(moves: @moves)
      end

      def show
        user = current_resource_owner
        @game = PlayLogic::GameLogic::GameManager.get_user_game(
          game_id: params[:id],
          user: user,
        )
        @game.requesting_user_id = user.id

        @moves = PlayLogic::MoveLogic::MoveManager.get_game_moves(
          game_id: params[:id],
        )

        json_response(game: @game, moves: @moves)
      end

      def create
        user = current_resource_owner
        @game = PlayLogic::GameLogic::GameManager.create_game_or_enqueue_for_user(
          user: user,
        )
        @game.requesting_user_id = user.id

        json_response(game: @game)
      end

      def update
        user = current_resource_owner
        @game = PlayLogic::GameLogic::GameManager.update_game(
          game_id: params[:id],
          user: user,
          params: @permitted_params
        )
        @game.requesting_user_id = user.id

        json_response(game: @game)
      end

      def destroy
        user = current_resource_owner
        @game = PlayLogic::GameLogic::GameManager.delete_user_game(
          game_id: params[:id],
          user: user,
        )
        @game.requesting_user_id = user.id

        json_response(game: @game)
      end

      def index_params
        @permitted_params = params.permit(PlayLogic::GameLogic::GameManager::GAME_INDEX_PARAMS).to_h
      end

      def move_params
        @permitted_params = params.permit([:game_id]).to_h
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

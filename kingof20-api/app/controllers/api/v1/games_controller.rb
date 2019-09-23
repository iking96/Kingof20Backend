# frozen_string_literal: true

module Api
  module V1
    class GamesController < ApplicationController
      def index
        @games = GameLogic::GameManager.get_user_games_with_params(
          user: current_resource_owner,
          _params: params
        )

        json_response(@games)
      end

      def create
        @game = GameLogic::GameManager.create_game_or_enqueue_for_user(
          user: current_resource_owner,
        )

        json_response(@game)
      end
    end
  end
end

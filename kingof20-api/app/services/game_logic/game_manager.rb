# frozen_string_literal: true

module GameLogic
  class GameManager
    USER_GAME_QUERY_PARAMS = [:initiator, :opponent].freeze
    class << self
      def get_user_games_with_params(user:, params:)
        games = user.games.to_a
        params.each do |key, value|
          games = reduce_by_param(
            games: games,
            user: user,
            key: key,
            _value: value
          )
        end
        games
      end

      def get_user_game(game_id:, user:)
        user.games.find_by!(id: game_id)
      end

      def create_game_or_enqueue_for_user(user:)
        paired_game = GameLogic::GameQueueEntryManager.pair_user(user: user)
        return paired_game if paired_game

        Game.transaction do
          new_game = mock_to_game_create(game_mock: GameLogic::Data::GameMock.new(user: user))
          GameLogic::GameQueueEntryManager.enqueue_game(game: new_game)
          new_game
        end
      end

      def delete_user_game(game_id:, user:)
        game = get_user_game(game_id: game_id, user: user)

        # TODO: Ensure game is in good state to delete
        game.destroy
      end

      private

      def reduce_by_param(games:, user:, key:, _value:)
        case key
        when "initiator"
          games = games.select { |g| g.initiator == user }
        when "opponent"
          games = games.select { |g| g.opponent == user }
        end
        games
      end

      def game_to_mock(game:)
      end

      def mock_to_game_update(game_mock:, game_to_update:)
      end

      def mock_to_game_create(game_mock:)
        Game.create!(
          board: game_mock.board,
          initiator_score:  game_mock.initiator_score,
          initiator_rack:  game_mock.initiator_rack,
          opponent_score:  game_mock.opponent_score,
          opponent_rack:  game_mock.opponent_rack,
          initiator:  game_mock.initiator,
          current_player:  game_mock.current_player,
          complete:  game_mock.complete,
          available_tiles:  game_mock.available_tiles,
        )
      end
    end
  end
end

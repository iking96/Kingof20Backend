# frozen_string_literal: true

module GameLogic
  class GameManager
    class << self
      def get_user_games_with_params(user:, _params:)
        user.games
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

      private

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

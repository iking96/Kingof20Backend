# frozen_string_literal: true

module PlayLogic
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
          paired_game = PlayLogic::GameQueueEntryLogic::GameQueueEntryManager.pair_user(user: user)
          return paired_game if paired_game

          Game.transaction do
            new_game = Game.create!(initiator: user)
            PlayLogic::GameQueueEntryLogic::GameQueueEntryManager.enqueue_game(game: new_game)
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
          when 'initiator'
            games = games.select { |g| g.initiator == user }
          when 'opponent'
            games = games.select { |g| g.opponent == user }
          end
          games
        end
      end
    end
  end
end

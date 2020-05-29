# frozen_string_literal: true

module PlayLogic
  module GameLogic
    class GameManager
      GAME_INDEX_PARAMS = [:initiator, :opponent, :all].freeze
      GAME_UPDATE_PARAMS = [:forfit].freeze
      class << self
        def get_user_games_with_params(user:, params:)
          options = params.keys
          if options.include?('all')
            games = user.games.to_a
          else
            games = user.visible_games.to_a
          end

          games = games.select { |g| g.initiator == user } if options.include?('initiator')
          games = games.select { |g| g.opponent == user } if options.include?('opponent')

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

        def update_game(game_id:, user:, params:)
          options = params.keys
          game = user.games.find_by!(id: game_id)

          # Check game is not over
          raise Error::Game::ProcessingError.new(
            error_code: :game_already_complete
          ) if game.complete?

          game.forfit_user(user: user) if options.include?('forfit')
          game.save!
          game
        end

        def delete_user_game(game_id:, user:)
          game = get_user_game(game_id: game_id, user: user)
          game.game_queue_entries.destroy_all
          game.forfit_user(user: user) unless game.complete?
          game.hide_from_user(user: user)
          game.save!
          game
        end
      end
    end
  end
end

# frozen_string_literal: true

module PlayLogic
  module GameQueueEntryLogic
    class GameQueueEntryManager
      class << self
        def pair_user(user:)
          GameQueueEntry.transaction do
            oldest_game_queue_entry = GameQueueEntry.where.not(user: user).first
            return nil unless oldest_game_queue_entry
            oldest_game_queue_entry.lock!
            oldest_waiting_game = oldest_game_queue_entry.game
            oldest_game_queue_entry.delete
            oldest_waiting_game.lock!
            oldest_waiting_game.update!(opponent: user)
            oldest_waiting_game
          end
        end

        def enqueue_game(game:)
          GameQueueEntry.create!(user: game.initiator, game: game)
        rescue ActiveRecord::RecordNotUnique
          raise Error::Game::ProcessingError.new(error_code: :game_already_queued)
        rescue ActiveRecord::RecordInvalid => e
          raise Error::Game::ProcessingError.new(error_code: :game_already_queued) if e.record.errors[:user_id].any?
          raise
        end

        def dequeue_game(game:)
          game.game_queue_entries.destroy_all
        end
      end
    end
  end
end

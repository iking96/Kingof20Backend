# frozen_string_literal: true

module GameLogic
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
      rescue ActiveRecord::RecordNotFound
        retry
      end

      def enqueue_game(game:)
        GameQueueEntry.create!(
          user: game.initiator,
          game: game,
        )
      end
    end
  end
end

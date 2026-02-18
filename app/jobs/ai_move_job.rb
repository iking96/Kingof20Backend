class AiMoveJob < ApplicationJob
  queue_as :ai_moves

  def perform(game_id)
    game = Game.find(game_id)
    return unless game.current_turn_is_ai? && !game.complete?

    PlayLogic::MoveLogic::MoveManager.trigger_ai_move_if_needed(game)

    # Explicitly broadcast after AI move completes
    game.reload
    GamesChannel.broadcast_to(game.initiator, 'refresh')
  end
end

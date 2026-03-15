# frozen_string_literal: true

module Ai
  class EasyAi < BaseAi
    # Never pick a move with score more than this above the best available
    QUALITY_FLOOR = 5
    # Number of top moves to randomly pick from (rubber-banding adjusts this)
    K_LOSING  = 1   # AI is losing — play near-optimally to stay competitive
    K_NEUTRAL = 3   # Scores are close — moderate variety
    K_WINNING = 5   # AI is winning — more varied play to let human back in
    # Score gap (points) that triggers rubber-banding
    RUBBER_BAND_THRESHOLD = 10

    def make_move
      valid_moves = find_all_valid_moves
      valid_moves = filter_superset_moves(valid_moves)

      if valid_moves.empty?
        can_swap? ? execute_swap : execute_pass
        return
      end

      scored = valid_moves.map { |m| [m, calculate_move_score(m)] }.sort_by(&:last)
      best_score = scored.first.last

      if can_swap? && SWAP_PENALTY < best_score
        execute_swap
        return
      end

      floor_threshold = best_score + QUALITY_FLOOR
      filtered = scored.select { |_, s| s <= floor_threshold }
      k = rubber_band_k
      selected, = filtered.first(k).sample

      execute_move(selected)
    end

    private

    # K shrinks when AI is losing (plays closer to optimal) and grows when winning.
    # AI is opponent; lower score = winning in this game.
    # Positive diff means AI has higher (worse) score = AI is losing.
    def rubber_band_k
      diff = @game.opponent_score - @game.initiator_score
      if diff > RUBBER_BAND_THRESHOLD
        K_LOSING
      elsif diff < -RUBBER_BAND_THRESHOLD
        K_WINNING
      else
        K_NEUTRAL
      end
    end
  end
end

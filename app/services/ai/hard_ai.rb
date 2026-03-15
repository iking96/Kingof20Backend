# frozen_string_literal: true

module Ai
  class HardAi < BaseAi
    def make_move
      valid_moves = find_all_valid_moves
      valid_moves = filter_superset_moves(valid_moves)

      if valid_moves.empty?
        can_swap? ? execute_swap : execute_pass
        return
      end

      best_move, best_score = valid_moves.map { |m| [m, calculate_move_score(m)] }.min_by(&:last)

      if can_swap? && SWAP_PENALTY < best_score
        execute_swap
        return
      end

      execute_move(best_move)
    end
  end
end

# frozen_string_literal: true

module Ai
  class HardAi < BaseAi
    # Only evaluate top N moves for lookahead (performance optimization)
    LOOKAHEAD_CANDIDATES = 5
    # Weight for penalizing moves that leave good opportunities for opponent.
    # Keep low — acts as a tiebreaker, not the primary decision factor.
    OPPONENT_PENALTY_WEIGHT = 0.1

    def make_move
      valid_moves = find_all_valid_moves
      valid_moves = filter_superset_moves(valid_moves)

      if valid_moves.empty?
        can_swap? ? execute_swap : execute_pass
        return
      end

      candidates = valid_moves.sort_by { |m| calculate_move_score(m) }.first(EQUITY_CANDIDATES)
      moves_with_equity = candidates.map { |m| [m, move_equity(m)] }
      best_equity = moves_with_equity.map(&:last).min

      if can_swap? && SWAP_PENALTY < best_equity
        execute_swap
        return
      end

      # Take top candidates by equity, then apply opponent lookahead as tiebreaker.
      # Pass pre-computed equity to avoid recomputing inside score_with_lookahead.
      lookahead_candidates = moves_with_equity.sort_by(&:last).first(LOOKAHEAD_CANDIDATES)
      best_move, = lookahead_candidates.max_by { |move, equity| score_with_lookahead(move, equity) }

      execute_move(best_move)
    end

    private

    # Score a move for lookahead tiebreaking. Accepts pre-computed equity to avoid
    # redundant calculation. Returns higher values for better moves.
    def score_with_lookahead(move, equity)
      base_score = -equity # negate so higher = better

      simulated_board = apply_move_to_board(move)
      human_rack = @game.initiator_rack.dup

      opponent_moves = find_moves_for_rack(simulated_board, human_rack)
      if opponent_moves.any?
        best_opponent_score = opponent_moves.map { |m| calculate_move_score(m, simulated_board) }.min
        if best_opponent_score < SWAP_PENALTY
          base_score -= (SWAP_PENALTY - best_opponent_score) * OPPONENT_PENALTY_WEIGHT
        end
      end

      base_score
    end
  end
end

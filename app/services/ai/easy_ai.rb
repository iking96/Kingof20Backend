# frozen_string_literal: true

module Ai
  class EasyAi < BaseAi
    # Never play a move scoring worse than this
    MAX_ACCEPTABLE_SCORE = 10
    # Minimum tiles in bag to consider swapping
    MIN_BAG_SIZE_FOR_SWAP = 10

    def make_move
      valid_moves = find_all_valid_moves
      valid_moves = filter_superset_moves(valid_moves)

      if valid_moves.empty?
        if can_swap?
          execute_swap
        else
          execute_pass
        end
      else
        # Filter to only acceptable moves (score <= 10)
        acceptable_moves = valid_moves.select { |m| calculate_move_score(m) <= MAX_ACCEPTABLE_SCORE }

        if acceptable_moves.empty?
          # All moves are bad - swap if possible, otherwise play best available
          if can_swap?
            execute_swap
          else
            best_move = valid_moves.min_by { |m| calculate_move_score(m) }
            execute_move(best_move)
          end
        else
          # Weighted random: better moves are more likely to be picked
          execute_move(weighted_random_move(acceptable_moves))
        end
      end
    end

    private

    def can_swap?
      @game.allow_swap? && @game.available_tiles.size >= MIN_BAG_SIZE_FOR_SWAP
    end

    def execute_swap
      # Simple swap: just swap random tiles (no sophisticated analysis like Hard AI)
      tiles_to_swap = @rack.sample([3, @rack.size].min)
      execute_move(move_type: 'swap', returned_tiles: tiles_to_swap)
    end

    # Weighted random selection: better moves (lower scores) are more likely
    # A move scoring 0 has weight 11, scoring 5 has weight 6, scoring 10 has weight 1
    def weighted_random_move(moves)
      weights = moves.map { |m| (MAX_ACCEPTABLE_SCORE + 1) - calculate_move_score(m) }
      total_weight = weights.sum

      random_value = rand * total_weight
      cumulative = 0

      moves.each_with_index do |move, i|
        cumulative += weights[i]
        return move if random_value < cumulative
      end

      moves.last # Fallback (shouldn't reach here)
    end
  end
end

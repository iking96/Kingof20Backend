# frozen_string_literal: true

module Ai
  class EasyAi < BaseAi
    # Bonus for moves closer to center
    CENTER_BONUS_WEIGHT = 0.5
    # Bonus for using more tiles (develops rack)
    TILE_USAGE_WEIGHT = 2
    # Only swap if best move scores worse than this (swap penalty is 10)
    SWAP_THRESHOLD = 10
    # Minimum tiles in bag to consider swapping
    MIN_BAG_SIZE_FOR_SWAP = 10

    def make_move
      valid_moves = find_all_valid_moves
      valid_moves = filter_superset_moves(valid_moves)

      if valid_moves.empty?
        can_swap? ? execute_swap : execute_pass
      else
        best_move = valid_moves.max_by { |m| score_move(m) }
        best_game_score = calculate_move_score(best_move)

        if best_game_score > SWAP_THRESHOLD && can_swap?
          execute_swap
        else
          execute_move(best_move)
        end
      end
    end

    private

    # Score a move using game score plus secondary heuristics
    def score_move(move)
      score = 0.0

      # Primary: Minimize distance from 20 (lower score = better)
      move_score = calculate_move_score(move)
      score -= move_score

      # Secondary: Prefer moves closer to board center
      center = Game::BOARD_SIZE / 2.0
      rows = move[:row_num]
      cols = move[:col_num]
      avg_row = rows.sum.to_f / rows.size
      avg_col = cols.sum.to_f / cols.size
      distance_from_center = Math.sqrt((avg_row - center)**2 + (avg_col - center)**2)
      max_distance = Math.sqrt(2) * center
      center_score = (max_distance - distance_from_center) / max_distance
      score += center_score * CENTER_BONUS_WEIGHT

      # Tertiary: Prefer using more tiles (develops rack faster)
      score += move[:tile_value].size * TILE_USAGE_WEIGHT

      score
    end

    def can_swap?
      @game.allow_swap? && @game.available_tiles.size >= MIN_BAG_SIZE_FOR_SWAP
    end

    def execute_swap
      # Simple swap: just swap random tiles (no sophisticated analysis)
      tiles_to_swap = @rack.sample([4, @rack.size].min)
      execute_move(move_type: 'swap', returned_tiles: tiles_to_swap)
    end
  end
end

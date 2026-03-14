# frozen_string_literal: true

module Ai
  class HardAi < BaseAi
    # Only swap if best move scores worse than this (swap penalty is 10)
    SWAP_THRESHOLD = 10
    # Minimum tiles in bag to consider swapping
    MIN_BAG_SIZE_FOR_SWAP = 10
    # Only evaluate top N moves for lookahead (performance optimization)
    LOOKAHEAD_CANDIDATES = 10
    # Weight for penalizing moves that leave good opportunities for opponent
    # Keep this low - it's a tiebreaker, not the primary decision factor
    OPPONENT_PENALTY_WEIGHT = 0.1
    # Minimum tiles to swap (swapping just 1 tile is inefficient for a 10-point penalty)
    MIN_SWAP_TILES = 2

    def make_move
      valid_moves = find_all_valid_moves
      valid_moves = filter_superset_moves(valid_moves)

      if valid_moves.empty?
        if can_swap?
          execute_swap([])
        else
          execute_pass
        end
      else
        best_move = select_best_move_with_lookahead(valid_moves)
        best_game_score = calculate_move_score(best_move)

        if best_game_score > SWAP_THRESHOLD && can_swap?
          execute_swap(valid_moves)
        else
          execute_move(best_move)
        end
      end
    end

    private

    def select_best_move_with_lookahead(valid_moves)
      # Sort by base score (lower = better), take top candidates
      candidates = valid_moves.sort_by { |m| calculate_move_score(m) }.first(LOOKAHEAD_CANDIDATES)

      candidates.max_by { |move| score_with_lookahead(move) }
    end

    def score_with_lookahead(move)
      base_score = -calculate_move_score(move) # Negate so higher = better

      # Simulate this move on the board
      simulated_board = apply_move_to_board(move)

      # Get human player's rack (AI "cheats" — common in single-player games)
      # The AI plays as "opponent", so the human is "initiator"
      human_rack = @game.initiator_rack.dup

      # Find human's best response using their real tiles
      opponent_moves = find_moves_for_rack(simulated_board, human_rack)
      if opponent_moves.any?
        best_opponent_score = opponent_moves.map { |m| calculate_move_score_on_board(m, simulated_board) }.min
        # Penalize if opponent has a good response (low score = good for them)
        if best_opponent_score < 10
          base_score -= (10 - best_opponent_score) * OPPONENT_PENALTY_WEIGHT
        end
      end

      base_score
    end

    def can_swap?
      @game.allow_swap? && @game.available_tiles.size >= MIN_BAG_SIZE_FOR_SWAP
    end

    def execute_swap(valid_moves)
      tiles_to_swap = identify_bad_tiles(valid_moves)
      execute_move(move_type: 'swap', returned_tiles: tiles_to_swap)
    end

    def identify_bad_tiles(valid_moves)
      return identify_bad_tiles_by_heuristics if valid_moves.empty?

      # Sort moves by game score (lower = better)
      sorted_moves = valid_moves.sort_by { |m| calculate_move_score(m) }

      # Take top 25% of moves (at least 3, cap at 20 for performance)
      top_count = [[sorted_moves.size / 4, 3].max, 20].min
      better_moves = sorted_moves.first(top_count)

      # Count how often each tile appears in better moves
      tile_frequency = Hash.new(0)
      better_moves.each do |move|
        move[:tile_value].each { |tile| tile_frequency[tile] += 1 }
      end

      # Sort rack tiles by frequency (ascending) - least useful first
      sorted_tiles = @rack.sort_by { |tile| tile_frequency[tile] }

      # Only swap tiles that appear in less than half the better moves
      threshold = better_moves.size / 2
      bad_tiles = sorted_tiles.select { |t| tile_frequency[t] < threshold }.take(3)

      # Ensure we swap at least MIN_SWAP_TILES (swapping just 1 is inefficient)
      if bad_tiles.size < MIN_SWAP_TILES
        bad_tiles = sorted_tiles.first(MIN_SWAP_TILES)
      end

      bad_tiles
    end

    def identify_bad_tiles_by_heuristics
      numbers = @rack.select { |t| t <= 9 }
      operators = @rack.select { |t| t >= 10 }
      bad_tiles = []

      # Priority 1: Duplicate tiles (having 2+ of same tile rarely helps)
      @rack.tally.each do |tile, count|
        (count - 1).times { bad_tiles << tile } if count > 1
      end

      # Priority 2: Imbalanced rack
      if operators.size > numbers.size
        excess = operators.size - numbers.size
        bad_tiles.concat(operators.take(excess))
      elsif numbers.size > operators.size + 1
        excess = numbers.size - operators.size - 1
        bad_tiles.concat(numbers.take(excess))
      end

      bad_tiles = bad_tiles.uniq.take(3)

      # Ensure we swap at least MIN_SWAP_TILES (swapping just 1 is inefficient)
      if bad_tiles.size < MIN_SWAP_TILES
        bad_tiles = @rack.first(MIN_SWAP_TILES)
      end

      bad_tiles
    end
  end
end

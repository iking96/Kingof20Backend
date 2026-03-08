# frozen_string_literal: true

module Ai
  class HardAi < BaseAi
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
        if can_swap?
          execute_swap([])
        else
          execute_pass
        end
      else
        best_move = valid_moves.max_by { |m| score_move(m) }
        best_game_score = calculate_move_score(best_move)

        if best_game_score > SWAP_THRESHOLD && can_swap?
          execute_swap(valid_moves)
        else
          execute_move(best_move)
        end
      end
    end

    private

    def score_move(move)
      score = 0.0

      # Primary: Minimize distance from 20 (lower score = better)
      # The game awards points as |20 - expression_result|
      # So we want moves that get closest to 20 (score of 0)
      move_score = calculate_move_score(move)
      score -= move_score # Lower game score is better, so subtract

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

    def calculate_move_score(move)
      # Simulate placing the move on a copy of the board and calculate score
      test_board = @board.map(&:dup)
      move[:row_num].each_with_index do |row, i|
        col = move[:col_num][i]
        tile = move[:tile_value][i]
        test_board[row][col] = tile
      end

      # Create a mock move object for scoring
      mock_move = MoveFinder::MockMove.new(
        row_num: move[:row_num],
        col_num: move[:col_num],
        tile_value: move[:tile_value]
      )

      result = PlayLogic::GameLogic::GameHelpers.score_board_with_move(
        board: test_board,
        move: mock_move
      )

      result.success? ? result.value : 999
    end

    # Filter out moves that are dominated by shorter moves at the same position.
    # A longer move is dominated if a shorter prefix scores strictly better.
    # Equal scores favor the longer move (uses more tiles, disposes of "overs").
    def filter_superset_moves(moves)
      dominated = Set.new

      moves.each do |longer|
        moves.each do |shorter|
          next if shorter[:tile_value].size >= longer[:tile_value].size
          next unless prefix_of?(shorter, longer)

          shorter_score = calculate_move_score(shorter)
          longer_score = calculate_move_score(longer)

          # Only cull if shorter scores STRICTLY better
          dominated.add(longer) if shorter_score < longer_score
        end
      end

      moves.reject { |m| dominated.include?(m) }
    end

    def prefix_of?(shorter, longer)
      shorter[:row_num] == longer[:row_num].first(shorter[:tile_value].size) &&
        shorter[:col_num] == longer[:col_num].first(shorter[:tile_value].size)
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

      # Ensure at least 1 tile to swap
      bad_tiles.presence || [sorted_tiles.first]
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

      bad_tiles.uniq.take(3).presence || @rack.take(1)
    end
  end
end

# frozen_string_literal: true

module Ai
  class HardAi < BaseAi
    # Bonus for moves closer to center
    CENTER_BONUS_WEIGHT = 0.5
    # Bonus for using more tiles (develops rack)
    TILE_USAGE_WEIGHT = 2

    def make_move
      valid_moves = find_all_valid_moves

      if valid_moves.empty?
        execute_pass
      else
        # Score each move and pick the best
        best_move = valid_moves.max_by { |m| score_move(m) }
        execute_move(best_move)
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
  end
end

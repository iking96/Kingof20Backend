# frozen_string_literal: true

module Ai
  class MoveFinder
    # Lightweight struct for move validation (faster than OpenStruct)
    MockMove = Struct.new(:row_num, :col_num, :tile_value, keyword_init: true)
    def initialize(game)
      @game = game
      @board = game.board.map(&:dup)
      @rack = game.opponent_rack.dup
    end

    def find_all_moves
      valid_moves = []

      # For each possible tile combination (1 to 3 tiles, since max placement is 3)
      (1..3).each do |num_tiles|
        @rack.combination(num_tiles).to_a.uniq.each do |tiles|
          tiles.permutation.to_a.uniq.each do |tile_perm|
            # Try horizontal and vertical placements
            valid_moves.concat(find_placements_for_tiles(tile_perm, :horizontal))
            valid_moves.concat(find_placements_for_tiles(tile_perm, :vertical))
          end
        end
      end

      valid_moves.uniq { |m| [m[:row_num], m[:col_num], m[:tile_value]] }
    end

    private

    def find_placements_for_tiles(tiles, orientation)
      valid_moves = []
      board_size = Game::BOARD_SIZE

      if orientation == :horizontal
        # For each row, find empty positions and try combinations
        (0...board_size).each do |row|
          empty_cols = (0...board_size).select { |col| @board[row][col].zero? }
          next if empty_cols.size < tiles.size

          # Try all combinations of empty positions for placing tiles
          empty_cols.combination(tiles.size).each do |cols|
            positions = cols.map { |col| [row, col] }
            move = build_move(positions, tiles)
            valid_moves << move if move_is_valid?(move)
          end
        end
      else
        # For each column, find empty positions and try combinations
        (0...board_size).each do |col|
          empty_rows = (0...board_size).select { |row| @board[row][col].zero? }
          next if empty_rows.size < tiles.size

          # Try all combinations of empty positions for placing tiles
          empty_rows.combination(tiles.size).each do |rows|
            positions = rows.map { |row| [row, col] }
            move = build_move(positions, tiles)
            valid_moves << move if move_is_valid?(move)
          end
        end
      end

      valid_moves
    end

    def build_move(positions, tiles)
      {
        move_type: 'tile_placement',
        row_num: positions.map(&:first),
        col_num: positions.map(&:last),
        tile_value: tiles,
      }
    end

    def move_is_valid?(move)
      # Simulate placing tiles on a test board
      test_board = @board.map(&:dup)
      move[:row_num].each_with_index do |row, i|
        col = move[:col_num][i]
        tile = move[:tile_value][i]
        test_board[row][col] = tile
      end

      # Create mock move object
      mock_move = MockMove.new(
        row_num: move[:row_num],
        col_num: move[:col_num],
        tile_value: move[:tile_value]
      )

      # Check board legality
      board_legality = PlayLogic::GameLogic::GameHelpers.check_board_legality(board: test_board)
      return false unless board_legality.success?

      # Check move legality
      move_legality = PlayLogic::GameLogic::GameHelpers.check_board_with_move_legality(
        board: test_board,
        move: mock_move
      )
      return false unless move_legality.success?

      # Check scoring is valid (no fractions, negatives, etc.)
      score_result = PlayLogic::GameLogic::GameHelpers.score_board_with_move(
        board: test_board,
        move: mock_move
      )
      return false unless score_result.success?

      true
    end
  end
end

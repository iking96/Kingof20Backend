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

    STARTING_ROWS = [2, 3].freeze
    STARTING_COLS = [2, 3].freeze

    def board_empty?
      @board[2][2].zero? && @board[2][3].zero? && @board[3][2].zero? && @board[3][3].zero?
    end

    def positions_near_gaps_horizontal(row, empty_cols, num_tiles)
      gap_edges = empty_cols.select do |col|
        (col > 0 && !@board[row][col - 1].zero?) ||
          (col < Game::BOARD_SIZE - 1 && !@board[row][col + 1].zero?)
      end
      return [] if gap_edges.empty?

      max_distance = num_tiles - 1
      empty_cols.select do |col|
        gap_edges.any? { |edge| (col - edge).abs <= max_distance }
      end
    end

    def positions_near_gaps_vertical(col, empty_rows, num_tiles)
      gap_edges = empty_rows.select do |row|
        (row > 0 && !@board[row - 1][col].zero?) ||
          (row < Game::BOARD_SIZE - 1 && !@board[row + 1][col].zero?)
      end
      return [] if gap_edges.empty?

      max_distance = num_tiles - 1
      empty_rows.select do |row|
        gap_edges.any? { |edge| (row - edge).abs <= max_distance }
      end
    end

    def find_empty_board_placements(tiles)
      return [] if tiles.size != 3

      valid_moves = []

      # Horizontal: rows 2-3, positions 0-5 (extending from starting cols 2-3)
      STARTING_ROWS.each do |row|
        positions_range = [0, 2 - (tiles.size - 1)].max..[3 + (tiles.size - 1), Game::BOARD_SIZE - 1].min
        empty_cols = positions_range.select { |col| @board[row][col].zero? }

        empty_cols.each_cons(tiles.size) do |cols|
          next unless cols.any? { |c| STARTING_COLS.include?(c) }

          positions = cols.map { |col| [row, col] }
          move = build_move(positions, tiles)
          valid_moves << move if move_is_valid?(move)
        end
      end

      # Vertical: cols 2-3, positions 0-5 (extending from starting rows 2-3)
      STARTING_COLS.each do |col|
        positions_range = [0, 2 - (tiles.size - 1)].max..[3 + (tiles.size - 1), Game::BOARD_SIZE - 1].min
        empty_rows = positions_range.select { |row| @board[row][col].zero? }

        empty_rows.each_cons(tiles.size) do |rows|
          next unless rows.any? { |r| STARTING_ROWS.include?(r) }

          positions = rows.map { |row| [row, col] }
          move = build_move(positions, tiles)
          valid_moves << move if move_is_valid?(move)
        end
      end

      valid_moves
    end

    def find_placements_for_tiles(tiles, orientation)
      return find_empty_board_placements(tiles) if board_empty?

      valid_moves = []
      board_size = Game::BOARD_SIZE

      if orientation == :horizontal
        (0...board_size).each do |row|
          empty_cols = (0...board_size).select { |col| @board[row][col].zero? }
          next if empty_cols.size < tiles.size

          pruned_cols = positions_near_gaps_horizontal(row, empty_cols, tiles.size)
          next if pruned_cols.size < tiles.size

          pruned_cols.each_cons(tiles.size) do |cols|
            positions = cols.map { |col| [row, col] }
            move = build_move(positions, tiles)
            valid_moves << move if move_is_valid?(move)
          end
        end
      else
        (0...board_size).each do |col|
          empty_rows = (0...board_size).select { |row| @board[row][col].zero? }
          next if empty_rows.size < tiles.size

          pruned_rows = positions_near_gaps_vertical(col, empty_rows, tiles.size)
          next if pruned_rows.size < tiles.size

          pruned_rows.each_cons(tiles.size) do |rows|
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

# frozen_string_literal: true

module PlayLogic
  module GameLogic
    class GameHelpers
      class << self
        def add_move_to_board(board:, rows:, cols:, tile_values:)
          tiles_placed = rows.count

          moves_causing_error = []
          (0...tiles_placed).each do |index|
            row = rows[index]
            col = cols[index]
            if board[row][col] != 0
              moves_causing_error << [row, col]
            end
          end

          unless moves_causing_error.empty?
            return Utilities::CheckResult.new(
              success: false,
              error_codes: [:game_space_taken],
            )
          end

          (0...tiles_placed).each do |index|
            row = rows[index]
            col = cols[index]
            tile_value = tile_values[index]
            board[row][col] = tile_value
          end

          Utilities::CheckResult.new(
            success: true,
            value: board,
          )
        end

        # TODO: Change to return all errors!!!
        def remove_tiles_from_rack(tiles:, rack:)
          errors = []
          if tiles.count > 3
            errors << :game_rack_requrest_to_long
          end

          unless tiles.subtract_once(rack).empty?
            errors << :game_tiles_not_on_rack
          end

          rack = rack.subtract_once(tiles)

          if errors.present?
            Utilities::CheckResult.new(
              success: false,
              error_codes: errors.uniq,
            )
          else
            Utilities::CheckResult.new(
              success: true,
              value: rack,
            )
          end
        end

        def check_board_legality(board:)
          errors = []

          unless check_board_on_starting(board: board)
            errors << :game_no_tile_on_starting
          end

          unless check_board_for_islands(board: board)
            errors << :game_board_contains_islands
          end

          if errors.present?
            Utilities::CheckResult.new(
              success: false,
              error_codes: errors.uniq,
            )
          else
            Utilities::CheckResult.new(
              success: true,
            )
          end
        end

        def check_board_with_move_legality(board:, move:)
          errors = []

          unless check_move_not_double_digit(
            board: board,
            rows: move.row_num,
            cols: move.col_num,
            values: move.tile_value,
          )
            errors << :move_creates_double_digit
          end

          unless check_move_not_double_expression(board: board)
            errors << :move_creates_double_expression
          end

          if errors.present?
            Utilities::CheckResult.new(
              success: false,
              error_codes: errors.uniq,
            )
          else
            Utilities::CheckResult.new(
              success: true,
            )
          end
        end

        private

        def check_board_on_starting(board:)
          (board[2][2] != 0) ||
          (board[2][3] != 0) ||
          (board[3][2] != 0) ||
          (board[3][3] != 0)
        end

        def check_board_for_islands(board:)
          visited = Array.new(Game.board_size) { Array.new(Game.board_size) { false } }

          island_found = false
          (0...Game.board_size).each do |row|
            (0...Game.board_size).each do |col|
              next unless board[row][col] != 0 && !visited[row][col]

              return false if island_found
              island_found = true

              flood_board_island(board: board, visited: visited, row: row, col: col)
            end
          end

          true
        end

        def flood_board_island(board:, visited:, row:, col:)
          return if !in_bounds?(row: row, col: col) ||
            board[row][col] == 0 ||
            visited[row][col] == true

          visited[row][col] = true

          [[1, 0], [-1, 0], [0, 1], [0, -1]].each do |row_delta, col_delta|
            flood_board_island(
              board: board,
              visited: visited,
              row: row + row_delta,
              col: col + col_delta
            )
          end
        end

        def check_move_not_double_digit(board:, rows:, cols:, values:)
          rows.zip(cols, values).all do |row, col, value|
            [[1, 0], [-1, 0], [0, 1], [0, -1]].all do |row_delta, col_delta|
              next unless in_bounds?(row: row, col: col)

              (number_tile?(board[row + row_delta][col + col_delta]) && operation_tile?(value)) ||
              (operation_tile?(board[row + row_delta][col + col_delta]) && number_tile?(value))
            end
          end
        end

        def check_move_not_double_expression(board:)
          true
        end

        def in_bounds?(row:, col:)
          (0...Game.board_size).include?(row) &&
          (0...Game.board_size).include?(col)
        end

        def number_tile?(value:)
          (1..9).include?(value)
        end

        def operation_tile?(value:)
          (10..13).include?(value)
        end
      end
    end
  end
end

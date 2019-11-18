# frozen_string_literal: true

module PlayLogic
  module GameLogic
    class GameHelpers
      class << self
        def add_move_to_board(board:, move:)
          rows = move.row_num
          cols = move.col_num
          tile_values = move.tile_value

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

        # Checks legality of a game board with the context of
        # last move to be played
        # Params:
        # +board+:: A Board object
        # +move+:: A Move object
        # Returns:
        # A CheckResult object with success status and optional errors
        def check_board_with_move_legality(board:, move:)
          errors = []

          unless check_move_not_double_digit(
            board: board,
            rows: move.row_num,
            cols: move.col_num,
          )
            errors << :move_creates_double_digit
          end

          unless check_move_not_double_expression(
            board: board,
            rows: move.row_num,
            cols: move.col_num,
          )
            errors << :move_creates_double_expression
          end

          unless check_move_not_dangling_operation(
            board: board,
            rows: move.row_num,
            cols: move.col_num,
          )
            errors << :move_creates_dangling_operation
          end

          unless check_move_not_lone_integer(
            board: board,
            rows: move.row_num,
            cols: move.col_num,
          )
            errors << :move_creates_lone_integer
          end

          unless check_move_not_separate_expressions(
            board: board,
            rows: move.row_num,
            cols: move.col_num,
          )
            errors << :move_spans_expressions
          end

          # TODO: Move does not build of existing stuff

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

        # Checks score of a game board with the context of
        # last move to be played
        # Params:
        # +board+:: A Board object
        # +move+:: A Move object
        # Returns:
        # A CheckResult object with success status and optional errors
        def score_board_with_move(board:, move:)
          move_row = move.row_num.first
          move_col = move.col_num.first

          # Move orientation can be determined by one tile
          orientation_result = check_expression_orientation(
            board: board,
            row: move_row,
            col: move_col,
          )

          if orientation_result.value.include?(:horizontal)
            PlayLogic::ScoreHelpers.score_board_slice(
              board_slice: board[move_row],
              start: move_col,
            )
          else
            PlayLogic::ScoreHelpers.score_board_slice(
              board_slice: board.transpose[move_col],
              start: move_row,
            )
          end
        end

        def in_bounds?(row:, col:)
          (0...Game.board_size).include?(row) &&
          (0...Game.board_size).include?(col)
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

        def check_move_not_double_digit(board:, rows:, cols:)
          rows.zip(cols).all? do |row, col|
            value = board[row][col]
            [[1, 0], [-1, 0], [0, 1], [0, -1]].all? do |row_delta, col_delta|
              next true unless in_bounds?(row: row + row_delta, col: col + col_delta)
              next true unless board[row + row_delta][col + col_delta] != 0

              (board[row + row_delta][col + col_delta].number_tile? && value.operation_tile?) ||
              (board[row + row_delta][col + col_delta].operation_tile? && value.number_tile?)
            end
          end
        end

        def check_move_not_double_expression(board:, rows:, cols:)
          rows.zip(cols).all? do |row, col|
            orientation_result = check_expression_orientation(
              board: board,
              row: row,
              col: col,
            )

            !(orientation_result.value.include?(:vertical) &&
            orientation_result.value.include?(:horizontal))
          end
        end

        def check_move_not_dangling_operation(board:, rows:, cols:)
          rows.zip(cols).all? do |row, col|
            next true if board[row][col].number_tile?

            orientation_result = check_expression_orientation(
              board: board,
              row: row,
              col: col,
            )

            orientation_result.value.include?(:vertical) ||
            orientation_result.value.include?(:horizontal)
          end
        end

        def check_move_not_lone_integer(board:, rows:, cols:)
          rows.zip(cols).all? do |row, col|
            next true if board[row][col].operation_tile?

            orientation_result = check_expression_orientation(
              board: board,
              row: row,
              col: col,
            )

            orientation_result.value.include?(:vertical) ||
            orientation_result.value.include?(:horizontal)
          end
        end

        def check_move_not_separate_expressions(board:, rows:, cols:)
          move_row = rows.first
          move_col = cols.first

          # Move orientation can be determined by one tile
          orientation_result = check_expression_orientation(
            board: board,
            row: move_row,
            col: move_col,
          )

          if orientation_result.value.include?(:horizontal)
            (cols.min..cols.max).none? do |index|
              board[move_row][index].zero?
            end
          else
            (rows.min..rows.max).none? do |index|
              board[index][move_col].zero?
            end
          end
        end

        def check_expression_orientation(board:, row:, col:)
          orientations = []
          directions = []

          if in_bounds?(row: row + 1, col: col) && board[row + 1][col] != 0
            directions << :down_one
          end

          if in_bounds?(row: row - 1, col: col) && board[row - 1][col] != 0
            directions << :up_one
          end

          if in_bounds?(row: row, col: col + 1) && board[row][col + 1] != 0
            directions << :right_one
          end

          if in_bounds?(row: row, col: col - 1) && board[row][col - 1] != 0
            directions << :left_one
          end

          if board[row][col].operation_tile?
            expression_vert = directions.include?(:up_one) && directions.include?(:down_one)
            expression_horz = directions.include?(:left_one) && directions.include?(:right_one)

            orientations << :horizontal if expression_horz
            orientations << :vertical if expression_vert

            return Utilities::CheckResult.new(
              success: true,
              value: orientations,
            )
          end

          if in_bounds?(row: row + 2, col: col) && board[row + 2][col] != 0
            directions << :down_two
          end

          if in_bounds?(row: row - 2, col: col) && board[row - 2][col] != 0
            directions << :up_two
          end

          if in_bounds?(row: row, col: col + 2) && board[row][col + 2] != 0
            directions << :right_two
          end

          if in_bounds?(row: row, col: col - 2) && board[row][col - 2] != 0
            directions << :left_two
          end

          expression_left = directions.include?(:left_one) && directions.include?(:left_two)
          expression_right = directions.include?(:right_one) && directions.include?(:right_two)
          expression_up = directions.include?(:up_one) && directions.include?(:up_two)
          expression_down = directions.include?(:down_one) && directions.include?(:down_two)

          orientations << :horizontal if expression_left || expression_right
          orientations << :vertical if expression_up || expression_down

          Utilities::CheckResult.new(
            success: true,
            value: orientations,
          )
        end
      end
    end
  end
end

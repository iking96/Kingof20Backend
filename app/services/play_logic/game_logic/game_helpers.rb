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

        def remove_tiles_from_rack(tiles:, rack:, max:)
          errors = []
          if tiles.count > max
            errors << :game_rack_request_too_long
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

        def return_tiles_to_available_tiles(tiles:, available_tiles:)
          available_tiles.push(*tiles)
          available_tiles.shuffle

          Utilities::CheckResult.new(
            success: true,
            value: available_tiles,
          )
        end

        def check_board_legality(board:)
          # Note: Island checking removed as redundant.
          # check_move_builds_from_placed_tiles already ensures all moves
          # connect to existing tiles, making islands impossible.
          if check_board_on_starting(board: board)
            Utilities::CheckResult.new(success: true)
          else
            Utilities::CheckResult.new(
              success: false,
              error_codes: [:game_no_tile_on_starting],
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

          unless check_move_not_multiple_expressions(
            board: board,
            rows: move.row_num,
            cols: move.col_num,
          )
            errors << :move_creates_multiple_expressions
          end

          unless check_move_builds_from_placed_tiles(
            board: board,
            rows: move.row_num,
            cols: move.col_num,
          )
            errors << :move_not_building
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

        def evaluate_end_game(game:)
          return unless game.available_tiles.empty?
          return if game.complete?

          if game.stage == 'in_play'
            game.stage = 'end_round_one'
          end

          return unless game.current_player == 'opponent'

          case game.stage
          when 'end_round_one'
            game.stage = 'end_round_two'
          when 'end_round_two'
            game.stage = 'complete'
          end
        end

        BOARD_SIZE = Game::BOARD_SIZE

        def in_bounds?(row:, col:)
          row >= 0 && row < BOARD_SIZE && col >= 0 && col < BOARD_SIZE
        end

        private

        def check_board_on_starting(board:)
          (board[2][2] != 0) ||
          (board[2][3] != 0) ||
          (board[3][2] != 0) ||
          (board[3][3] != 0)
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

        def check_move_not_multiple_expressions(board:, rows:, cols:)
          return true if rows.count <= 1

          move_is_vertical = rows.uniq.count > 1
          move_is_horizontal = cols.uniq.count > 1

          rows.zip(cols).all? do |row, col|
            orientation_result = check_expression_orientation(
              board: board,
              row: row,
              col: col,
            )

            if move_is_vertical
              orientation_result.value.include?(:vertical)
            elsif move_is_horizontal
              orientation_result.value.include?(:horizontal)
            else
              true
            end
          end
        end

        def check_move_builds_from_placed_tiles(board:, rows:, cols:)
          first_move = board.sum { |row| row.count { |cell| !cell.zero? } } <= 3
          return true if first_move

          move_row = rows.first
          move_col = cols.first

          # Move orientation can be determined by one tile
          orientation_result = check_expression_orientation(
            board: board,
            row: move_row,
            col: move_col,
          )

          expression_coordinates = []
          if orientation_result.value.include?(:horizontal)
            board_slice = board[move_row]
            move_col -= 1 while move_col - 1 >= 0 && !board_slice[move_col - 1].zero?
            while move_col < Game.board_size && !board_slice[move_col].zero?
              expression_coordinates << [move_row, move_col, board_slice[move_col]]
              move_col += 1
            end
          else
            board_slice = board.transpose[move_col]
            move_row -= 1 while move_row - 1 >= 0 && !board_slice[move_row - 1].zero?
            while move_row < Game.board_size && !board_slice[move_row].zero?
              expression_coordinates << [move_row, move_col, board_slice[move_row]]
              move_row += 1
            end
          end

          # Pop first and/or last element from expression_coordinates if it is an operation
          expression_coordinates.shift if expression_coordinates.any? && expression_coordinates.first[2].operation_tile?
          expression_coordinates.pop if expression_coordinates.any? && expression_coordinates.last[2].operation_tile?

          move_coordinates = rows.zip(cols)
          expression_coordinates = expression_coordinates.map { |coord| [coord[0], coord[1]] }

          !(expression_coordinates - move_coordinates).empty?
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

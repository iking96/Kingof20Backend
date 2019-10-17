# frozen_string_literal: true

module GameLogic
  class Helpers
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
          if block_given?
            yield("Spaces #{moves_causing_error} already occupied on board")
          else
            raise ArgumentError, "Space #{moves_causing_error} already occupied on board"
          end
          return nil
        end

        (0...tiles_placed).each do |index|
          row = rows[index]
          col = cols[index]
          tile_value = tile_values[index]
          board[row][col] = tile_value
        end

        board
      end
    end
  end
end

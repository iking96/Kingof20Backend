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

        def remove_tiles_from_rack(tiles:, rack:)
          if tiles.count > 3
            if block_given?
              yield("Attempting to remove #{tiles.count} from rack; max is 3")
            else
              raise ArgumentError, "Attempting to remove #{tiles.count} from rack; max is 3"
            end
            return nil
          end

          unless tiles.subtract_once(rack).empty?
            if block_given?
              yield("Tiles (#{tiles}) not all in rack (#{rack})")
            else
              raise ArgumentError, "Tiles (#{tiles}) not all in rack (#{rack})"
            end
            return nil
          end

          rack.subtract_once(tiles)
        end

        def check_board_legality(board:)
          # TODO: [self onStarting]
          # [self countIslands]
          # [self findScore]
        end

        private

      end
    end
  end
end

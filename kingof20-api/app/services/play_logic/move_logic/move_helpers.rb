# frozen_string_literal: true

module PlayLogic
  module MoveLogic
    class MoveHelpers
      class << self
        def move_pre_processor(move:)
          errors = []
          if !move.tile_placement? && !move.swap? && !move.pass?
            errors << 'missing arguments for pre-processing'
            return errors
          end

          if move.tile_placement?
            if !move.row_num.present? || !move.col_num.present? || !move.tile_value.present?
              errors << 'missing arguments for pre-processing'
            else
              errors << 'row input size must be less than or equal 3' unless move.row_num.count <= 3
              errors << 'col input size must be less than or equal 3' unless move.col_num.count <= 3
              unless move.tile_value.count <= 3
                errors << 'tile_value size input must be less than or equal 3'
              end
              unless move.row_num.count == move.col_num.count && move.col_num.count == move.tile_value.count
                errors << 'row, col and tile_value input must be same length'
              end
              unless [move.row_num, move.col_num].transpose.uniq!.nil?
                errors << 'row and col cannot contain duplicates'
              end
              unless move.row_num.all? { |row| (0..Game.board_size).include?(row) }
                errors << "row numbers must be in: [0..#{Game.board_size}]"
              end
              unless move.col_num.all? { |col| (0..Game::BOARD_SIZE).include?(col) }
                errors << "col numbers must be in: [0..#{Game.board_size}]"
              end
              unless move.tile_value.all? { |tile| Game::TILES_MAPPING.keys.include?(tile) }
                errors << "tile values must be in: #{Game::TILES_MAPPING.keys}"
              end
              unless move.row_num.same_values? || move.col_num.same_values?
                errors << 'move must be in a stright line'
              end
            end
          elsif move.swap?
            if !move.returned_tiles.present?
              errors << 'missing arguments for pre-processing'
            else
              unless move.returned_tiles.count <= Game.rack_size
                errors << "returned tiles size must be less than or equal #{Game.rack_size}"
              end
              unless move.returned_tiles.all? { |tile| Game::TILES_MAPPING.keys.include?(tile) }
                errors << "returned tiles values must be in: #{Game::TILES_MAPPING.keys}"
              end
            end
          end

          # No additional checks needed for pass

          errors <<  "id #{move.user_id} does not exist in User" unless User.exists?(id: move.user_id)
          errors <<  "id #{move.game_id} does not exist in Game" unless Game.exists?(id: move.game_id)
          unless move.user && move.user.games.pluck(:id).include?(move.game_id)
            errors << "Game id #{move.game_id} does not belong to User #{move.user_id}"
          end

          errors
        end
      end
    end
  end
end

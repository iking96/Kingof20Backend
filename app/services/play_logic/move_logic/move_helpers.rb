# frozen_string_literal: true

module PlayLogic
  module MoveLogic
    class MoveHelpers
      class << self
        def move_pre_processor(move:)
          errors = []
          if !move.tile_placement? && !move.swap? && !move.pass?
            errors << :move_missing_arguments
          elsif move.tile_placement?
            if !move.row_num.present? || !move.col_num.present? || !move.tile_value.present?
              errors << :move_missing_arguments
            else
              errors << :move_input_to_long unless move.row_num.count <= 3
              errors << :move_input_to_long unless move.col_num.count <= 3
              errors << :move_input_to_long unless move.tile_value.count <= 3
              unless move.row_num.count == move.col_num.count && move.col_num.count == move.tile_value.count
                errors << :move_input_mismatch
              end
              unless !errors.include?(:move_input_mismatch) && [move.row_num, move.col_num].transpose.uniq!.nil?
                errors << :move_input_duplicate
              end
              unless move.row_num.all? { |row| (0..Game.board_size).include?(row) }
                errors << :move_row_col_invalid
              end
              unless move.col_num.all? { |col| (0..Game::BOARD_SIZE).include?(col) }
                errors << :move_row_col_invalid
              end
              unless move.tile_value.all? { |tile| Game::TILES_MAPPING.keys.include?(tile) }
                errors << :move_tile_value_invalid
              end
              unless move.row_num.same_values? || move.col_num.same_values?
                errors << :move_strightness
              end
            end
          elsif move.swap?
            if !move.returned_tiles.present?
              errors << :move_missing_arguments
            else
              unless move.returned_tiles.count <= Game.rack_size
                errors << :move_swap_input_to_long
              end
              unless move.returned_tiles.all? { |tile| Game::TILES_MAPPING.keys.include?(tile) }
                errors << :move_tile_value_invalid
              end
            end
          end

          # No additional checks needed for pass

          errors <<  :move_user_does_not_exist unless User.exists?(id: move.user_id)
          errors <<  :move_game_does_not_exist unless Game.exists?(id: move.game_id)
          unless move.user && move.user.games.pluck(:id).include?(move.game_id)
            errors << :move_user_does_not_own_game
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
      end
    end
  end
end

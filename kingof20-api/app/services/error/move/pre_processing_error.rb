# frozen_string_literal: true

module Error
  module Move
    class PreProcessingError < CustomError
      PRE_PROCESSING_ERRORS = {
        move_pre_processing_error: 'unable to pre-process move',
        move_missing_arguments: 'missing arguments for pre-processing',
        move_input_to_long: 'move input size must be less than or equal 3',
        move_input_mismatch: 'row, col and tile_value input must be same length',
        move_input_duplicate: 'row and col cannot contain duplicates',
        move_row_col_invalid: "row and col numbers must be in: [0..#{::Game.board_size}]",
        move_tile_value_invalid: "tile values must be in: #{::Game::TILES_MAPPING.keys}",
        move_strightness: 'move must be in a stright line',
        move_swap_input_to_long: "returned tiles size must be less than or equal #{::Game.rack_size}",
        move_user_does_not_exist: 'id did not exist in User',
        move_game_does_not_exist: 'id did not exist in Game',
        move_user_does_not_own_game: 'Game id did not belong to User',
      }.freeze

      def initialize(error_code: :move_pre_processing_error)
        error_message = PRE_PROCESSING_ERRORS[error_code]

        raise ArgumentError, "No PreProcessingError for #{error_code}" if error_message.nil?

        super(
          error: :unprocessable_entity,
          error_code: error_code,
          status: 422,
          message: error_message
        )
      end
    end
  end
end

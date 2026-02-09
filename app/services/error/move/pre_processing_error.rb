# frozen_string_literal: true

module Error
  module Move
    class PreProcessingError < CustomError
      PRE_PROCESSING_ERRORS = {
        move_pre_processing_error: 'Unable to process your move',
        move_missing_arguments: 'Move is missing required information',
        move_input_to_long: 'You can only place up to 3 tiles per turn',
        move_input_mismatch: 'Invalid move data',
        move_input_duplicate: 'Cannot place multiple tiles in the same space',
        move_row_col_invalid: 'Tile placement is outside the board',
        move_tile_value_invalid: 'Invalid tile value',
        move_strightness: 'Tiles must be placed in a straight line',
        move_swap_input_to_long: 'Too many tiles selected for exchange',
        move_user_does_not_exist: 'User not found',
        move_game_does_not_exist: 'Game not found',
        move_user_does_not_own_game: 'You are not a player in this game',
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

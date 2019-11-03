# frozen_string_literal: true

module Error
  module Move
    class ProcessingError < CustomError
      PROCESSING_ERRORS = {
        move_processing_error: 'unable to process move',
        move_not_current_player: 'User is not current player',
        game_rack_requrest_to_long: 'attempt to remove more than 3 tiles during turn',
        game_tiles_not_on_rack: 'tiles to remove not all in rack',
        game_space_taken: 'space already occupied on board',
      }.freeze

      def initialize(error_code: 'unable to process move')
        error_message = PROCESSING_ERRORS[error_code]

        raise ArgumentError, "No ProcessingError for #{error_code}" if error_message.nil?

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

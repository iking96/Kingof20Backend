# frozen_string_literal: true

module Error
  module Move
    class ProcessingError < CustomError
      PROCESSING_ERRORS = {
        move_processing_error: 'Unable to process your move',
        move_not_current_player: "It's not your turn",
      }.freeze

      def initialize(error_code: :move_processing_error)
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

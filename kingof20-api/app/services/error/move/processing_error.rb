# frozen_string_literal: true

module Error
  module Move
    class ProcessingError < CustomError
      def initialize(message: 'unable to process move')
        super(
          error: :unprocessable_entity,
          error_code: 'move-2',
          status: 422,
          message: message
        )
      end
    end
  end
end

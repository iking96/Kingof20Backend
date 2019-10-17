# frozen_string_literal: true

module Error
  module Move
    class PreProcessingError < CustomError
      def initialize(message: 'unable to pre-process move')
        super(
          error: :unprocessable_entity,
          error_code: 'move-1',
          status: 422,
          message: message
        )
      end
    end
  end
end

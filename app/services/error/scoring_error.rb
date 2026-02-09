# frozen_string_literal: true

module Error
  class ScoringError < CustomError
    SCORING_ERRORS = {
      expression_scoring_error: 'Unable to calculate expression',
      expression_causes_negative: 'Expression cannot result in a negative number',
      expression_causes_fraction: 'Expression cannot result in a fraction',
    }.freeze

    def initialize(error_code: :expression_scoring_error)
      error_message = SCORING_ERRORS[error_code]

      raise ArgumentError, "No ScoringError for #{error_code}" if error_message.nil?

      super(
        error: :unprocessable_entity,
        error_code: error_code,
        status: 422,
        message: error_message
      )
    end
  end
end

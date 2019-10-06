# frozen_string_literal: true

module Error
  class CustomError < StandardError
    attr_reader :status, :error, :message

    def initialize(error: nil, error_code: nil, status: nil, message: nil)
      @error = error || 422
      @error_code = error_code || 'king-1'
      @status = status || :unprocessable_entity
      @message = message || 'Something went wrong'
    end

    def fetch_json
      Helpers::Render.json(error, message, status)
    end
  end
end

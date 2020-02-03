# frozen_string_literal: true

module Error
  module Concerns
    class Render
      def self.json(error, error_code, status, message)
        {
          error: error,
          error_code: error_code,
          status: status,
          message: message,
        }.as_json
      end
    end
  end
end

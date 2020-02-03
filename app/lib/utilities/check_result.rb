# frozen_string_literal: true

module Utilities
  class CheckResult
    attr_reader :value

    def initialize(success:, value: nil, error_codes: [])
      @success = success
      @value = value
      @error_codes = error_codes
      freeze
    end

    def success?
      @success
    end

    def failure?
      !success?
    end

    def errors
      @error_codes
    end
  end
end

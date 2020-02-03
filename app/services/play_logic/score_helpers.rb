# frozen_string_literal: true

module PlayLogic
  class ScoreHelpers
    class << self
      def score_board_slice(board_slice:, start:)
        # Expect start to be somewhere on an expression
        if start >= Game.board_size || start < 0 ||
          board_slice[start].zero?
          return Utilities::CheckResult.new(
            success: false,
            error_codes: [:expression_not_found],
          )
        end

        index = start
        index -= 1 while index - 1 > 0 && !board_slice[index - 1].zero?
        index += 1 while index < Game.board_size && board_slice[index].operation_tile?

        result = board_slice[index]

        while index + 1 < Game.board_size && index + 2 < Game.board_size &&
          board_slice[index + 1].operation_tile? && board_slice[index + 2].number_tile?

          operation = board_slice[index + 1]
          number = board_slice[index + 2]

          case operation
          when 10
            result += number
          when 11
            result *= number
          when 12
            result -= number

            if result.negative?
              return Utilities::CheckResult.new(
                success: false,
                error_codes: [:expression_causes_negative],
              )
            end
          when 13
            if result % number != 0
              return Utilities::CheckResult.new(
                success: false,
                error_codes: [:expression_causes_fraction],
              )
            end

            result /= number
          end

          index += 2
        end

        Utilities::CheckResult.new(
          success: true,
          value: (Game::TWENTY - result).abs,
        )
      end
    end
  end
end

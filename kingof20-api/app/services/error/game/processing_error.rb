# frozen_string_literal: true

module Error
  module Game
    class ProcessingError < CustomError
      PROCESSING_ERRORS = {
        game_processing_error: 'unable to process game',
        game_rack_requrest_to_long: 'attempt to remove more than 3 tiles during turn',
        game_tiles_not_on_rack: 'tiles to remove not all in rack',
        game_space_taken: 'space already occupied on board',
        game_no_tile_on_starting: 'game board has no tiles on starting space',
        game_board_contains_islands: 'game board contains islands',
        move_creates_double_digit: 'move on board created double digit',
        move_creates_double_expression: 'move on board created double expression',
        move_creates_dangling_operation: 'move on board created dangling operation',
        move_creates_lone_integer: 'move on board created lone integer',
        move_spans_expressions: 'move on board spans expressions',
      }.freeze

      def initialize(error_code: :game_processing_error)
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

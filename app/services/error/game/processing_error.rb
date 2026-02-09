# frozen_string_literal: true

module Error
  module Game
    class ProcessingError < CustomError
      PROCESSING_ERRORS = {
        game_processing_error: 'Unable to process your move',
        game_rack_request_too_long: 'Too many tiles were placed this turn',
        game_tiles_not_on_rack: 'Those tiles are not in your rack',
        game_space_taken: 'That space is already occupied',
        game_no_tile_on_starting: 'First move must cover the starting spaces',
        game_board_contains_islands: 'Tiles must connect to existing tiles on the board',
        game_already_complete: 'This game has already ended',
        game_no_tiles_remain: 'No tiles remaining in the game',
        move_creates_double_digit: 'Tiles cannot form a two-digit numbers',
        move_creates_double_expression: 'Tiles placed this turn cannot create multiple expressions at once',
        move_spans_expressions: 'Tiles placed this turn cannot create multiple expressions at once',
        move_creates_multiple_expressions: 'Tiles placed this turn cannot create multiple expressions at once',
        move_creates_dangling_operation: 'All tiles placed this turn must contribute to the expression',
        move_creates_lone_integer: 'All tiles placed this turn must contribute to the expression',
        move_not_building: 'Tiles must connect to existing tiles on the board',
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

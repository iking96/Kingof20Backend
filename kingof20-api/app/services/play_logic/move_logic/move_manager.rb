# frozen_string_literal: true

module PlayLogic
  module MoveLogic
    class MoveManager
      USER_MOVE_QUERY_PARAMS = [:perfect_twenty].freeze
      class << self
        def get_user_moves_with_params(user:, params:)
          moves = user.moves.to_a
          params.each do |key, value|
            moves = reduce_by_param(
              moves: moves,
              key: key,
              _value: value
            )
          end
          games
        end

        def create_move_and_update_game(user:, move_info:)
          new_move = Move.new(move_info)

          pre_processor_result = MoveLogic::MoveHelpers.move_pre_processor(move: new_move)
          raise Error::Move::PreProcessingError.new(
            error_code: pre_processor_result.errors.first
          ) unless pre_processor_result.success?

          Game.transaction do
            move_game = new_move.game

            # Check that user is current player
            unless move_game.current_user == user
              raise Error::Move::ProcessingError.new(
                message: 'User is not current player',
              )
            end

            # Check that rack can supply tiles
            new_rack = PlayLogic::GameLogic::GameHelpers.remove_tiles_from_rack(
              tiles: new_move.tile_value,
              rack: move_game.current_user_rack,
            ) do |message|
              raise Error::Move::ProcessingError.new(
                message: message
              )
            end

            move_game.set_current_user_rack(new_rack: new_rack)

            # Check that move is not blocked
            PlayLogic::GameLogic::GameHelpers.add_move_to_board(
              board: move_game.board,
              rows: new_move.row_num,
              cols: new_move.col_num,
              tile_values: new_move.tile_value,
            ) do |message|
              raise Error::Move::ProcessingError.new(
                message: message
              )
            end

            # TODO: Check game validity

            move_game.save!
            # new_move.save!
          end

          new_move
        end

        private

        def reduce_by_param(moves:, key:, _value:)
          case key
          when 'perfect_twenty'
            moves = moves.select { |m| m.result == 20 }
          end
          moves
        end
      end
    end
  end
end

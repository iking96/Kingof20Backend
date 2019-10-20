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

        def create_move_and_update_game(move_info:)
          new_move = Move.new(move_info)
          raise Error::Move::PreProcessingError.new(
            message: new_move.errors.to_a
          ) unless MoveLogic::MoveHelpers.move_pre_processor(move: new_move).empty?

          Game.transaction do
            move_game = new_move.game
            PlayLogic::Helpers.add_move_to_board(
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
            # TODO: Check rack validity

            # move_game.save!
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

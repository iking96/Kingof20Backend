# frozen_string_literal: true

module PlayLogic
  module MoveLogic
    class MoveManager
      USER_MOVE_QUERY_PARAMS = [:result].freeze
      class << self
        def get_user_moves_with_params(user:, params:)
          moves = user.moves.to_a
          params.each do |key, value|
            moves = reduce_by_param(
              moves: moves,
              key: key,
              value: value
            )
          end
          moves
        end

        def get_user_move(move_id:, user:)
          user.moves.find_by!(id: move_id)
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
                error_code: :move_not_current_player,
              )
            end

            # TODO: Check game is not over

            # Check that rack can supply tiles
            remove_tiles_result = PlayLogic::GameLogic::GameHelpers.remove_tiles_from_rack(
              tiles: new_move.tile_value,
              rack: move_game.current_user_rack,
            )
            if remove_tiles_result.success?
              new_rack = remove_tiles_result.value
            else
              raise Error::Game::ProcessingError.new(
                error_code: remove_tiles_result.errors.first
              )
            end

            move_game.set_current_user_rack(new_rack: new_rack)

            # Check that move can be added to board
            add_move_result = PlayLogic::GameLogic::GameHelpers.add_move_to_board(
              board: move_game.board,
              move: new_move,
            )

            unless add_move_result.success?
              raise Error::Game::ProcessingError.new(
                error_code: add_move_result.errors.first,
              )
            end

            # Check that board and move are legal
            board_legality_result = PlayLogic::GameLogic::GameHelpers.check_board_legality(
              board: move_game.board,
            )
            board_with_move_legality_result = PlayLogic::GameLogic::GameHelpers.check_board_with_move_legality(
              board: move_game.board,
              move: new_move,
            )

            unless board_legality_result.success?
              raise Error::Game::ProcessingError.new(
                error_code: board_legality_result.errors.first,
              )
            end
            unless board_with_move_legality_result.success?
              raise Error::Game::ProcessingError.new(
                error_code: board_with_move_legality_result.errors.first,
              )
            end

            # TODO: Update move game to progress with game

            move_game.save!
            # new_move.save!
          end

          new_move
        end

        private

        def reduce_by_param(moves:, key:, value:)
          case key
          when 'result'
            moves = moves.select { |move| move.result == value.to_i }
          end
          moves
        end
      end
    end
  end
end

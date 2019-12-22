# frozen_string_literal: true

module PlayLogic
  module MoveLogic
    class MoveManager
      USER_MOVE_QUERY_PARAMS = [:result].freeze
      SWAP_PASS_PENALTY = 10
      class << self
        def get_user_moves_with_params(user:, params:)
          options = params.keys
          moves = user.moves.to_a

          moves = moves.select { |move| move.result == params['result'].to_i } if options.include?('result')

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

            # Check game is not over
            if move_game.complete?
              raise Error::Game::ProcessingError.new(
                error_code: :game_already_complete,
              )
            end

            if new_move.move_type == 'tile_placement'
              handle_tile_placement(new_move: new_move, move_game: move_game)

              score_result = PlayLogic::GameLogic::GameHelpers.score_board_with_move(
                board: move_game.board,
                move: new_move,
              )

              if score_result.success?
                score_delta = score_result.value
              else
                raise Error::ScoringError.new(
                  error_code: score_result.errors.first,
                )
              end
            else
              # Disallow swapping and passing if tiles have run out
              if move_game.available_tiles.empty?
                raise Error::Game::ProcessingError.new(
                  error_code: :game_no_tiles_remain,
                )
              end
              is_swap = new_move.move_type == 'swap'
              handle_swap(new_move: new_move, move_game: move_game) if is_swap
              score_delta = SWAP_PASS_PENALTY
            end

            # Update game state
            current_score = move_game.current_user_score
            move_game.set_current_user_score(new_score: current_score + score_delta)
            move_game.refill_current_user_rack
            PlayLogic::GameLogic::GameHelpers.evaluate_end_game(game: move_game)
            move_game.toggle_current_user

            # Update move state
            new_move.result = score_delta
            new_move.move_number = move_game.moves.count + 1

            move_game.save!
            new_move.save!
          end

          new_move
        end

        private

        def handle_tile_placement(new_move:, move_game:)
          # Check that rack can supply tiles
          remove_tiles_result = PlayLogic::GameLogic::GameHelpers.remove_tiles_from_rack(
            tiles: new_move.tile_value,
            rack: move_game.current_user_rack,
            max: 3,
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
        end

        def handle_swap(new_move:, move_game:)
          # Check that rack can supply tiles
          remove_tiles_result = PlayLogic::GameLogic::GameHelpers.remove_tiles_from_rack(
            tiles: new_move.returned_tiles,
            rack: move_game.current_user_rack,
            max: Game.rack_size,
          )
          if remove_tiles_result.success?
            new_rack = remove_tiles_result.value
          else
            raise Error::Game::ProcessingError.new(
              error_code: remove_tiles_result.errors.first
            )
          end

          move_game.set_current_user_rack(new_rack: new_rack)

          # Return tiles to available tiles
          return_tiles_result = PlayLogic::GameLogic::GameHelpers.return_tiles_to_available_tiles(
            tiles: new_move.returned_tiles,
            available_tiles: move_game.available_tiles,
          )

          new_available_tiles = return_tiles_result.value
          move_game.available_tiles = new_available_tiles
        end
      end
    end
  end
end

# frozen_string_literal: true

module Ai
  class BaseAi
    def initialize(game)
      @game = game
      @rack = game.opponent_rack.dup
      @board = game.board.map(&:dup)
    end

    def make_move
      raise NotImplementedError, "Subclasses must implement make_move"
    end

    protected

    def execute_move(move_info)
      PlayLogic::MoveLogic::MoveManager.create_move_and_update_game(
        user: nil,
        move_info: move_info.merge(
          game_id: @game.id,
          user_id: nil
        ),
        is_ai: true
      )
    end

    def execute_pass
      execute_move(move_type: 'pass')
    end

    def find_all_valid_moves
      Ai::MoveFinder.new(@game).find_all_moves
    end
  end
end

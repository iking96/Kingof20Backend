# frozen_string_literal: true

module Ai
  class EasyAi < BaseAi
    def make_move
      valid_moves = find_all_valid_moves

      if valid_moves.empty?
        execute_pass
      else
        # Pick a random valid move
        execute_move(valid_moves.sample)
      end
    end
  end
end

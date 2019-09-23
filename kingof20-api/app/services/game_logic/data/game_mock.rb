# frozen_string_literal: true

module GameLogic
  module Data
    class GameMock
      attr_accessor :initiator,
      :current_player,
      :board,
      :available_tiles,
      :initiator_score,
      :initiator_rack,
      :opponent_score,
      :opponent_rack,
      :complete

      def initialize(user:)
        # Init players
        @initiator = user
        @current_player = user

        # Init game state
        @board = Array.new(Game.board_size) { Array.new(Game.board_size) { 0 } }
        @available_tiles = Game.initial_available_tiles.shuffle
        @initiator_score = 0
        @initiator_rack = @available_tiles.shift(7)
        @opponent_score = 0
        @opponent_rack = @available_tiles.shift(7)
        @complete = false
      end
    end
  end
end

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

    # Calculate the game score for a move (lower = better, 0 = perfect)
    def calculate_move_score(move)
      test_board = @board.map(&:dup)
      move[:row_num].each_with_index do |row, i|
        col = move[:col_num][i]
        tile = move[:tile_value][i]
        test_board[row][col] = tile
      end

      mock_move = MoveFinder::MockMove.new(
        row_num: move[:row_num],
        col_num: move[:col_num],
        tile_value: move[:tile_value]
      )

      result = PlayLogic::GameLogic::GameHelpers.score_board_with_move(
        board: test_board,
        move: mock_move
      )

      result.success? ? result.value : 999
    end

    # Filter out moves that are dominated by shorter moves at the same position.
    # A longer move is dominated if a shorter prefix scores strictly better.
    def filter_superset_moves(moves)
      dominated = Set.new

      moves.each do |longer|
        moves.each do |shorter|
          next if shorter[:tile_value].size >= longer[:tile_value].size
          next unless prefix_of?(shorter, longer)

          shorter_score = calculate_move_score(shorter)
          longer_score = calculate_move_score(longer)

          # Only cull if shorter scores STRICTLY better
          dominated.add(longer) if shorter_score < longer_score
        end
      end

      moves.reject { |m| dominated.include?(m) }
    end

    def prefix_of?(shorter, longer)
      shorter[:row_num] == longer[:row_num].first(shorter[:tile_value].size) &&
        shorter[:col_num] == longer[:col_num].first(shorter[:tile_value].size)
    end
  end
end

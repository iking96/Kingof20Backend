# frozen_string_literal: true

module Ai
  class BaseAi
    MIN_SWAP_TILES = 2
    MIN_BAG_SIZE_FOR_SWAP = 10
    # Worst possible single-move score: |20 - 0| or |20 - 40|
    LEAVE_NO_MOVES_PENALTY = 20

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

    def execute_swap
      tiles = best_swap_tiles
      execute_move(move_type: 'swap', returned_tiles: tiles)
    end

    def can_swap?
      @game.allow_swap? && @game.available_tiles.size >= MIN_BAG_SIZE_FOR_SWAP
    end

    def find_all_valid_moves
      Ai::MoveFinder.new(@game).find_all_moves
    end

    # Calculate the game score for a move (lower = better, 0 = perfect).
    # Accepts an optional board; defaults to the current game board.
    def calculate_move_score(move, board = @board)
      test_board = board.map(&:dup)
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

    # Returns the tiles to discard when swapping.
    # Keeps the subset of rack tiles that has the best potential three-tile combo score.
    # Always discards at least MIN_SWAP_TILES tiles.
    def best_swap_tiles
      best_score = Float::INFINITY
      best_kept = []

      (0..(@rack.size - MIN_SWAP_TILES)).each do |keep_count|
        @rack.combination(keep_count).each do |kept_subset|
          score = best_combo_score(kept_subset)
          if score < best_score
            best_score = score
            best_kept = kept_subset
          end
        end
      end

      @rack.subtract_once(best_kept)
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

          dominated.add(longer) if shorter_score < longer_score
        end
      end

      moves.reject { |m| dominated.include?(m) }
    end

    def prefix_of?(shorter, longer)
      shorter[:row_num] == longer[:row_num].first(shorter[:tile_value].size) &&
        shorter[:col_num] == longer[:col_num].first(shorter[:tile_value].size)
    end

    private

    # Best three-tile combo score achievable from the given rack in isolation.
    # Returns LEAVE_NO_MOVES_PENALTY if no valid three-tile expression exists.
    def best_combo_score(rack)
      return LEAVE_NO_MOVES_PENALTY if rack.size < 3

      best = LEAVE_NO_MOVES_PENALTY
      rack.combination(3).each do |combo|
        combo.permutation.each do |perm|
          next unless perm[0].number_tile? && perm[1].operation_tile? && perm[2].number_tile?
          score = evaluate_three_tile_expression(perm[0], perm[1], perm[2])
          best = [best, score].min if score
        end
      end
      best
    end

    def evaluate_three_tile_expression(a, op, b)
      case op
      when 10 then (Game::TWENTY - (a + b)).abs           # +
      when 11 then (Game::TWENTY - (a * b)).abs           # ×
      when 12
        return nil if a - b < 0                           # no negatives
        (Game::TWENTY - (a - b)).abs                      # -
      when 13
        return nil if b.zero? || a % b != 0               # must divide evenly
        (Game::TWENTY - (a / b)).abs                      # ÷
      end
    end
  end
end

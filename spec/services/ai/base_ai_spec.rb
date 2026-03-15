# frozen_string_literal: true

require 'rails_helper'

# BaseAi is abstract — use EasyAi as a concrete subclass to test BaseAi methods
RSpec.describe(Ai::BaseAi) do
  let(:user) { create(:user) }
  let(:game) { create(:game, :with_first_move, initiator: user, opponent: nil, ai_difficulty: 'easy') }
  let(:ai) { Ai::EasyAi.new(game) }

  describe '#best_available_score' do
    it 'returns LEAVE_NO_MOVES_PENALTY for an empty rack' do
      expect(ai.send(:best_available_score, game.board, []))
        .to(eq(Ai::BaseAi::LEAVE_NO_MOVES_PENALTY))
    end

    it 'returns LEAVE_NO_MOVES_PENALTY when no moves are found' do
      allow(ai).to(receive(:find_moves_for_rack).and_return([]))
      expect(ai.send(:best_available_score, game.board, [1, 2, 3]))
        .to(eq(Ai::BaseAi::LEAVE_NO_MOVES_PENALTY))
    end

    it 'returns the minimum available move score' do
      moves = [
        { move_type: 'tile_placement', row_num: [3], col_num: [2], tile_value: [5] },
        { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 4] },
      ]
      allow(ai).to(receive(:find_moves_for_rack).and_return(moves))
      allow(ai).to(receive(:calculate_move_score).and_return(8, 3))
      expect(ai.send(:best_available_score, game.board, [5, 11, 4])).to(eq(3))
    end
  end

  describe '#move_equity' do
    let(:move) { { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 1] } }

    it 'returns immediate score plus leave score' do
      allow(ai).to(receive(:calculate_move_score).with(move).and_return(5))
      allow(ai).to(receive(:best_available_score).and_return(8))
      expect(ai.send(:move_equity, move)).to(eq(13))
    end

    it 'computes leave rack by subtracting played tiles from rack' do
      # Default opponent_rack: [1, 2, 3, 4, 5, 6, 11]; move uses [11, 1]; leave: [2, 3, 4, 5, 6]
      expected_leave = game.opponent_rack.subtract_once([11, 1])
      allow(ai).to(receive(:calculate_move_score).and_return(0))
      expect(ai).to(receive(:best_available_score).with(anything, expected_leave).and_return(0))
      ai.send(:move_equity, move)
    end
  end

  describe '#best_swap_tiles' do
    it 'swaps at least MIN_SWAP_TILES tiles' do
      result = ai.send(:best_swap_tiles)
      expect(result.size).to(be >= Ai::BaseAi::MIN_SWAP_TILES)
    end

    it 'keeps tiles that form strong combos and discards weaker tiles' do
      # [4, 11, 5] = 4 × 5 = 20 (score 0, perfect) — should be kept
      # [13, 13, 13, 13] = ÷ tiles with no valid combos — should be swapped
      strong_combo_game = create(:game, :with_first_move,
        initiator: user,
        opponent: nil,
        ai_difficulty: 'easy',
        opponent_rack: [4, 11, 5, 13, 13, 13, 13])
      strong_ai = Ai::EasyAi.new(strong_combo_game)

      tiles_to_swap = strong_ai.send(:best_swap_tiles)

      expect(tiles_to_swap).not_to(include(4))
      expect(tiles_to_swap).not_to(include(5))
    end

    it 'handles a rack with no valid combos without error' do
      all_operators_game = create(:game, :with_first_move,
        initiator: user,
        opponent: nil,
        ai_difficulty: 'easy',
        opponent_rack: [10, 10, 11, 11, 12, 12, 13])
      bad_ai = Ai::EasyAi.new(all_operators_game)

      expect { bad_ai.send(:best_swap_tiles) }.not_to(raise_error)
      expect(bad_ai.send(:best_swap_tiles).size).to(be >= Ai::BaseAi::MIN_SWAP_TILES)
    end
  end
end

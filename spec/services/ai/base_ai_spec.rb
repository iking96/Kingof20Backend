# frozen_string_literal: true

require 'rails_helper'

# BaseAi is abstract — use EasyAi as a concrete subclass to test BaseAi methods
RSpec.describe(Ai::BaseAi) do
  let(:user) { create(:user) }
  let(:game) { create(:game, :with_first_move, initiator: user, opponent: nil, ai_difficulty: 'easy') }
  let(:ai) { Ai::EasyAi.new(game) }

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

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Ai::EasyAi) do
  let(:user) { create(:user) }
  let(:game) { create(:game, :with_first_move, initiator: user, opponent: nil, ai_difficulty: 'easy') }

  describe '#make_move' do
    subject { described_class.new(game).make_move }

    context 'when valid moves exist' do
      # Board has [5, 11, 4] at row 2, cols 2-4 (5 × 4 = 20)
      # Opponent rack is [1, 2, 3, 4, 5, 6, 11]
      # Valid move: place 11 (×) at (3,2) and 1 at (4,2) to make vertical 5 × 1 = 5
      let(:stubbed_moves) do
        [
          { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 1] },
        ]
      end

      before do
        allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return(stubbed_moves))
      end

      it 'makes a valid move' do
        expect { subject }.to_not(raise_error)
      end

      it 'creates a move record' do
        # with_first_move trait creates an initial move, so we check from current count
        expect { subject }.to(change { game.moves.count }.by(1))
      end
    end

    context 'when no valid moves exist' do
      before do
        allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return([]))
      end

      it 'executes a pass' do
        subject
        expect(Move.last.move_type).to(eq('pass'))
      end
    end
  end
end

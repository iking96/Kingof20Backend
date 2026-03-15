# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Ai::HardAi) do
  let(:user) { create(:user) }
  let(:game) { create(:game, :with_first_move, initiator: user, opponent: nil, ai_difficulty: 'hard') }

  describe '#make_move' do
    subject { described_class.new(game).make_move }

    context 'when valid moves exist' do
      let(:stubbed_moves) do
        [{ move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 1] }]
      end

      before do
        allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return(stubbed_moves))
      end

      it 'makes a valid move without error' do
        expect { subject }.to_not(raise_error)
      end

      it 'creates a move record' do
        expect { subject }.to(change { game.moves.count }.by(1))
      end
    end

    context 'when no valid moves exist' do
      before do
        allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return([]))
      end

      context 'and swapping is available' do
        it 'executes a swap' do
          subject
          expect(Move.last.move_type).to(eq('swap'))
        end
      end

      context 'and swapping is not available' do
        before { allow(game).to(receive(:allow_swap?).and_return(false)) }

        it 'executes a pass' do
          subject
          expect(Move.last.move_type).to(eq('pass'))
        end
      end
    end
  end

  describe 'move selection' do
    it 'always picks the lowest-scoring move' do
      # move_a is a prefix of move_b (same start position), but move_a scores 10 and move_b scores 3.
      # filter_superset_moves only removes longer moves dominated by shorter ones (shorter_score < longer_score).
      # Since move_a (10) is NOT < move_b (3), move_a does not dominate move_b — both survive the filter.
      # Use allow_any_instance_of (not expect) — stubs are consumed by both filter_superset_moves
      # and the main scoring loop; call count must not be constrained.
      move_a = { move_type: 'tile_placement', row_num: [3], col_num: [2], tile_value: [5] }
      move_b = { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 4] }

      allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return([move_a, move_b]))
      allow_any_instance_of(described_class).to(receive(:calculate_move_score).with(move_a).and_return(10))
      allow_any_instance_of(described_class).to(receive(:calculate_move_score).with(move_b).and_return(3))

      described_class.new(game).make_move
      expect(Move.last.tile_value).to(eq([11, 4]))
    end
  end

  describe 'swap behavior' do
    subject { described_class.new(game).make_move }

    context 'when best move equity exceeds SWAP_PENALTY' do
      let(:bad_move) do
        { move_type: 'tile_placement', row_num: [3], col_num: [2], tile_value: [1] }
      end

      before do
        allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return([bad_move]))
        allow_any_instance_of(described_class).to(receive(:calculate_move_score).with(bad_move).and_return(15))
      end

      it 'executes a swap' do
        subject
        expect(Move.last.move_type).to(eq('swap'))
      end
    end

    context 'when best move equity is at or below SWAP_PENALTY' do
      let(:good_move) do
        { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 1] }
      end

      before do
        allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return([good_move]))
        allow_any_instance_of(described_class).to(receive(:calculate_move_score).with(good_move).and_return(5))
      end

      it 'executes the move' do
        subject
        expect(Move.last.move_type).to(eq('tile_placement'))
      end
    end
  end
end

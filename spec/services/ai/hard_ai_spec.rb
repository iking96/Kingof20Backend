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
    it 'is deterministic — always picks the lowest equity move' do
      move_a = { move_type: 'tile_placement', row_num: [3], col_num: [2], tile_value: [5] }
      move_b = { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 4] }

      allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return([move_a, move_b]))
      allow_any_instance_of(described_class).to(receive(:move_equity).with(move_a).and_return(10))
      allow_any_instance_of(described_class).to(receive(:move_equity).with(move_b).and_return(3))
      # Stub lookahead to pass through equity-based ranking without interference
      allow_any_instance_of(described_class).to(receive(:score_with_lookahead) { |_, _m, eq| -eq })

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
        allow_any_instance_of(described_class).to(receive(:move_equity).and_return(15))
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
        allow_any_instance_of(described_class).to(receive(:move_equity).and_return(5))
      end

      it 'executes the move' do
        subject
        expect(Move.last.move_type).to(eq('tile_placement'))
      end
    end
  end

  describe 'lookahead tiebreaker' do
    it 'considers opponent response when scoring moves' do
      ai = described_class.new(game)
      move = { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 1] }
      expect(ai.send(:score_with_lookahead, move, 5)).to(be_a(Numeric))
    end

    it 'prefers the move that leaves the opponent in a weaker position' do
      move_a = { move_type: 'tile_placement', row_num: [3], col_num: [2], tile_value: [5] }
      move_b = { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 4] }

      allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return([move_a, move_b]))
      # Equal equity — lookahead is the tiebreaker
      allow_any_instance_of(described_class).to(receive(:move_equity).and_return(5))
      # move_a leaves opponent a great response; move_b leaves opponent weaker
      allow_any_instance_of(described_class).to(receive(:score_with_lookahead)
        .with(move_a, 5).and_return(-8.0))
      allow_any_instance_of(described_class).to(receive(:score_with_lookahead)
        .with(move_b, 5).and_return(-3.0))

      described_class.new(game).make_move
      expect(Move.last.tile_value).to(eq([11, 4]))
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Ai::EasyAi) do
  let(:user) { create(:user) }
  let(:game) { create(:game, :with_first_move, initiator: user, opponent: nil, ai_difficulty: 'easy') }

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

      it 'executes a swap instead of playing' do
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

  describe 'quality floor' do
    let(:good_move)     { { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 4] } }
    let(:terrible_move) { { move_type: 'tile_placement', row_num: [3], col_num: [2], tile_value: [1] } }

    before do
      allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves)
        .and_return([good_move, terrible_move]))
      allow_any_instance_of(described_class).to(receive(:move_equity)
        .with(good_move).and_return(2))
      allow_any_instance_of(described_class).to(receive(:move_equity)
        .with(terrible_move).and_return(2 + Ai::EasyAi::QUALITY_FLOOR + 1))
      allow_any_instance_of(described_class).to(receive(:filter_superset_moves) { |_, m| m })
    end

    it 'never selects a move that exceeds the quality floor above the best' do
      executed_tile_values = []
      allow_any_instance_of(described_class).to(receive(:execute_move)) do |_, move_info|
        executed_tile_values << move_info[:tile_value]
      end

      10.times { described_class.new(game).make_move }

      expect(executed_tile_values.compact).not_to(include([1]))
    end
  end

  describe '#rubber_band_k' do
    let(:ai) { described_class.new(game) }

    context 'when AI is losing by more than RUBBER_BAND_THRESHOLD' do
      # AI is opponent; lower score = winning; high opponent_score means AI is losing
      before do
        allow(game).to(receive(:opponent_score).and_return(Ai::EasyAi::RUBBER_BAND_THRESHOLD + 1))
        allow(game).to(receive(:initiator_score).and_return(0))
      end

      it 'returns K_LOSING' do
        expect(ai.send(:rubber_band_k)).to(eq(Ai::EasyAi::K_LOSING))
      end
    end

    context 'when scores are within RUBBER_BAND_THRESHOLD' do
      it 'returns K_NEUTRAL' do
        expect(ai.send(:rubber_band_k)).to(eq(Ai::EasyAi::K_NEUTRAL))
      end
    end

    context 'when AI is winning by more than RUBBER_BAND_THRESHOLD' do
      before do
        allow(game).to(receive(:opponent_score).and_return(0))
        allow(game).to(receive(:initiator_score).and_return(Ai::EasyAi::RUBBER_BAND_THRESHOLD + 1))
      end

      it 'returns K_WINNING' do
        expect(ai.send(:rubber_band_k)).to(eq(Ai::EasyAi::K_WINNING))
      end
    end
  end
end

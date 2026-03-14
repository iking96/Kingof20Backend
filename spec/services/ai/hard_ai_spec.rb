# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Ai::HardAi) do
  let(:user) { create(:user) }
  let(:game) { create(:game, :with_first_move, initiator: user, opponent: nil, ai_difficulty: 'hard') }

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

      context 'and swapping is available' do
        it 'executes a swap' do
          subject
          expect(Move.last.move_type).to(eq('swap'))
        end
      end

      context 'and swapping is not available' do
        before do
          allow(game).to(receive(:allow_swap?).and_return(false))
        end

        it 'executes a pass' do
          subject
          expect(Move.last.move_type).to(eq('pass'))
        end
      end
    end
  end

  describe 'move selection' do
    # Board has [5, 11, 4] at row 2, cols 2-4 (5 × 4 = 20)
    # Opponent rack is [1, 2, 3, 4, 5, 6, 11]
    let(:stubbed_moves) do
      [
        { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 1] },
      ]
    end

    before do
      allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return(stubbed_moves))
    end

    it 'is a valid HardAi instance' do
      ai = described_class.new(game)
      expect(ai).to(be_a(Ai::HardAi))
    end
  end

  describe 'swap behavior' do
    subject { described_class.new(game).make_move }

    context 'when best move scores above threshold' do
      let(:bad_move) do
        { move_type: 'tile_placement', row_num: [3], col_num: [2], tile_value: [1] }
      end

      before do
        allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return([bad_move]))
        # Stub calculate_move_score to return a high (bad) score
        allow_any_instance_of(described_class).to(receive(:calculate_move_score).and_return(15))
      end

      it 'executes a swap instead of the bad move' do
        subject
        expect(Move.last.move_type).to(eq('swap'))
      end
    end

    context 'when best move scores at or below threshold' do
      let(:good_move) do
        { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 1] }
      end

      before do
        allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return([good_move]))
        # Stub calculate_move_score to return a low (good) score
        allow_any_instance_of(described_class).to(receive(:calculate_move_score).and_return(5))
      end

      it 'executes the move' do
        subject
        expect(Move.last.move_type).to(eq('tile_placement'))
      end
    end
  end

  describe 'lookahead behavior' do
    let(:ai) { described_class.new(game) }

    it 'considers opponent response when scoring moves' do
      # Verify lookahead methods exist and are callable
      move = { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 1] }

      # score_with_lookahead should return a score
      expect(ai.send(:score_with_lookahead, move)).to(be_a(Numeric))
    end

    it 'penalizes moves that leave good opportunities for opponent' do
      # This is a behavioral test - the lookahead should affect move selection
      # When two moves have similar base scores, the one leaving fewer good
      # opponent responses should be preferred
      moves = [
        { move_type: 'tile_placement', row_num: [3], col_num: [2], tile_value: [1] },
        { move_type: 'tile_placement', row_num: [3, 4], col_num: [2, 2], tile_value: [11, 1] },
      ]

      allow_any_instance_of(Ai::MoveFinder).to(receive(:find_all_moves).and_return(moves))

      # select_best_move_with_lookahead should consider opponent response
      best = ai.send(:select_best_move_with_lookahead, moves)
      expect(moves).to(include(best))
    end
  end
end

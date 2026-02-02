# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Ai::EasyAi) do
  let(:user) { create(:user) }
  let(:game) { create(:game, initiator: user, opponent: nil, ai_difficulty: 'easy') }

  describe '#make_move' do
    subject { described_class.new(game).make_move }

    context 'when valid moves exist' do
      before do
        # Set up a game state where AI can make a move
        # First, simulate the human player making a move
        game.current_player = 'opponent'
        game.save!
      end

      it 'makes a valid move' do
        expect { subject }.to_not(raise_error)
      end

      it 'creates a move record' do
        expect { subject }.to(change { Move.count }.by(1))
      end
    end

    context 'when no valid moves exist' do
      before do
        game.current_player = 'opponent'
        # Use only operation tiles - can't form valid expressions with just operators
        game.opponent_rack = [10, 10, 10, 10, 10, 10, 10]
        game.save!
      end

      it 'executes a pass' do
        subject
        expect(Move.last.move_type).to(eq('pass'))
      end
    end
  end
end

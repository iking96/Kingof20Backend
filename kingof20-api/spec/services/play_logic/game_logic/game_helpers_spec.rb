# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PlayLogic::GameLogic::GameHelpers) do
  describe 'add_move_to_board' do
    subject do
      described_class.add_move_to_board(
        board: game.board,
        rows: rows,
        cols: cols,
        tile_values: [1],
      )
    end

    let!(:game) { create(:game_with_user, :with_first_move) }
    let(:rows) { [1] }
    let(:cols) { [1] }

    it 'adds the move to the board' do
      new_board = subject
      expect(new_board[1][1]).to(eq(1))
    end

    context 'move space is taken' do
      let(:rows) { [2] }
      let(:cols) { [2] }

      it 'raises an error' do
        expect { subject }.to(raise_error ArgumentError)
      end
    end
  end

  describe 'remove_tiles_from_rack' do
    subject do
      described_class.remove_tiles_from_rack(
        tiles: tiles,
        rack: rack,
      )
    end

    let!(:tiles) { [1, 2, 3] }
    let!(:rack) { [1, 2, 3, 4, 5, 6, 7] }

    it 'removes the tiles from the rack' do
      new_rack = subject
      expect(new_rack).to(eq([4, 5, 6, 7]))
    end

    context 'when rack contains duplicates' do
      let!(:rack) { [1, 2, 3, 3, 5, 6, 7] }

      it 'raises an error' do
        new_rack = subject
        expect(new_rack).to(eq([3, 5, 6, 7]))
      end
    end

    context 'when tiles.count >3' do
      let!(:tiles) { [1, 2, 3, 4] }

      it 'raises an error' do
        expect { subject }.to(raise_error ArgumentError)
      end
    end

    context 'when rack does not contain all tiles' do
      let!(:tiles) { [1, 2, 9] }

      it 'raises an error' do
        expect { subject }.to(raise_error ArgumentError)
      end
    end
  end
end

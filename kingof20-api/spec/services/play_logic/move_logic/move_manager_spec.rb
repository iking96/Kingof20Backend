# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PlayLogic::MoveLogic::MoveManager) do
  describe 'create_move_and_update_game' do
    subject { described_class.create_move_and_update_game(move_info: move_info) }

    let!(:game) { create(:game_with_user, :with_first_move) }
    let(:move_info) { {} }

    context 'there is no move_info' do
      it 'raises an error' do
        expect { subject }.to(raise_error Error::Move::PreProcessingError)
      end
    end

    context 'move_info is invalid' do
      let(:move_info) do
        {
          row_num: [1, 2, 20],
          col_num: [1, 2, 20],
          tile_value: [1, 2, 20],
        }
      end
      it 'raises an error' do
        expect { subject }.to(raise_error Error::Move::PreProcessingError)
      end
    end

    context 'move space is taken' do
      let(:row) { 2 }
      let(:col) { 2 }
      let(:move_info) do
        {
          game_id: game.id,
          user_id: game.initiator.id,
          move_type: :tile_placement,
          row_num: [row],
          col_num: [col],
          tile_value: [1],
        }
      end
      it 'raises an error' do
        expect { subject }.to(raise_error Error::Move::ProcessingError)
      end
    end

    context 'move is valid' do
      let(:move_info) do
        {
          game_id: game.id,
          user_id: game.initiator.id,
          move_type: :tile_placement,
          row_num: [0, 1],
          col_num: [2, 2],
          tile_value: [4, 11],
        }
      end

      it 'returns the created move' do
        # TODO: Complete test
        expect(subject).to(be_a(Move))
      end
    end
  end
end

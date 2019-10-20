# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PlayLogic::MoveLogic::MoveManager) do
  describe 'create_move_and_update_game' do
    subject { described_class.create_move_and_update_game(user: user, move_info: move_info) }

    let!(:game) { create(:game_with_user, :with_first_move) }
    let(:user) { game.initiator }
    let(:move_info) do
      {
        game_id: game.id,
        user_id: game.initiator.id,
        move_type: :tile_placement,
        row_num: row_num,
        col_num: col_num,
        tile_value: tile_value,
      }
    end
    let(:row_num) { [0, 1] }
    let(:col_num) { [2, 2] }
    let(:tile_value) { [4, 11] }

    it 'returns the created move' do
      # TODO: Complete test
      expect(subject).to(be_a(Move))
    end

    context 'there is no move_info' do
      let(:move_info) { {} }

      it 'raises an error' do
        expect { subject }.to(raise_error Error::Move::PreProcessingError)
      end
    end

    context 'it is not the users turn' do
      before do
        game.current_player = 'opponent'
        game.save!
      end

      it 'raises an error' do
        expect { subject }.to(raise_error(Error::Move::ProcessingError, 'User is not current player'))
      end
    end

    context 'move_info is invalid' do
      let(:row_num) { [1, 2, 20] }
      let(:col_num) { [1, 2, 20] }
      let(:tile_value) { [1, 2, 20] }

      it 'raises an error' do
        expect { subject }.to(raise_error Error::Move::PreProcessingError)
      end
    end

    context 'the rack cannot supply the tiles' do
      let(:tile_value) { [4, 10] }

      it 'raises an error' do
        expect { subject }.to(raise_error(Error::Move::ProcessingError, /not all in rack/))
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
        expect { subject }.to(raise_error Error::Move::ProcessingError, /already occupied on board/)
      end
    end
  end
end

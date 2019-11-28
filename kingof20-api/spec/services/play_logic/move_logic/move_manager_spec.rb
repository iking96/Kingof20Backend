# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PlayLogic::MoveLogic::MoveManager) do
  describe 'get_user_moves_with_params' do
    it "Tests are covered by Move controller; would be nice to add test here though."
  end

  describe 'get_user_move' do
    it "Tests are covered by Move controller; would be nice to add test here though."
  end

  describe 'create_move_and_update_game' do
    subject { described_class.create_move_and_update_game(user: user, move_info: move_info) }

    let!(:game) do
      create(
        :game_with_user,
        :with_first_move,
        opponent: user,
        initiator_rack: [1, 2, 3, 4, 5, 6, 11],
      )
    end
    let(:user) { create(:user) }
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
    let(:row_num) { [1, 3] }
    let(:col_num) { [3, 3] }
    let(:tile_value) { [3, 6] }
    let(:expected_board) do
      [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 5, 11, 4, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]
    end
    let(:expected_opponent_rack) { [1, 2, 4, 5, 11] }

    it 'returns the created move' do
      expect(subject).to(be_a(Move))
    end

    it 'updates the game appropriately' do
      # TODO: Complete test
      expect do
        subject
        game.reload
      end.to(
        change { game.moves.count }.by(1)
        .and(change { game.available_tiles.count }.by(-2))
      )
      expect(game.board).to(eq(expected_board))
      expect(game.opponent_rack).to(include(*expected_opponent_rack))
      expect(game.opponent_score).to(eq(2))
      expect(game.current_player).to(eq('initiator'))
    end

    context 'there is no move_info' do
      let(:move_info) { {} }

      it 'raises an error' do
        expect { subject }.to(raise_error Error::Move::PreProcessingError)
      end
    end

    context 'it is not the users turn' do
      before do
        game.current_player = 'initiator'
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
        expect { subject }.to(raise_error(Error::Game::ProcessingError, /not all in rack/))
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
        expect { subject }.to(raise_error(Error::Game::ProcessingError, /already occupied on board/))
      end
    end

    context 'board is not legal after move' do
      let!(:game) { create(:game_with_user) }
      let(:user) { game.initiator }
      let(:row_num) { [0, 0, 0] }
      let(:col_num) { [0, 1, 2] }
      let(:tile_value) { [4, 11, 5] }

      it 'raises an error' do
        expect { subject }.to(raise_error(Error::Game::ProcessingError, /game board has no tiles on starting space/))
      end
    end

    context 'board with move is not legal' do
      # Create double digit
      let(:row_num) { [2] }
      let(:col_num) { [1] }
      let(:tile_value) { [4] }

      it 'raises an error' do
        expect { subject }.to(raise_error(Error::Game::ProcessingError, /move on board created double digit/))
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(GameLogic::MoveManager) do
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
  end

  describe 'move_pre_processor' do
    subject { described_class.move_pre_processor(move: move) }

    let(:game) { create(:game_with_user) }
    let!(:move) do
      build(
        :move,
        row_num: nil,
        col_num: nil,
        tile_value: nil,
        move_number: nil,
        result: nil,
        returned_tiles: nil,
        game: game,
        user: game.initiator,
        move_type: 'tile_placement'
      )
    end

    context 'tests pre_processing conditions' do
      context 'for no type' do
        before do
          move.move_type = nil
        end

        it do
          expect(subject).to(include('missing arguments for pre-processing'))
        end
      end

      context 'for tile_placement type' do
        before do
          move.move_type = 'tile_placement'
        end

        it do
          expect(subject).to(include('missing arguments for pre-processing'))
        end

        it do
          move.row_num = [1, 2, 3, 4]
          move.col_num = [1, 2, 3, 4]
          move.tile_value = [1, 2, 3, 4]
          expect(subject).to(include(
            'row input size must be less than or equal 3',
            'col input size must be less than or equal 3',
            'tile_value size input must be less than or equal 3',
          ))
        end
        it do
          move.row_num = [1]
          move.col_num = [1]
          move.tile_value = [1, 2]
          expect(subject).to(include('row, col and tile_value input must be same length'))
        end
        it do
          move.row_num = [100]
          move.col_num = [100]
          move.tile_value = [100]
          expect(subject).to(include(
            'row numbers must be in: [0..12]',
            'col numbers must be in: [0..12]',
            'tile values must be in: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]',
          ))
        end
        it do
          move.row_num = [1, 2, 1]
          move.col_num = [1, 3, 1]
          move.tile_value = [1, 2, 3]
          expect(subject).to(include(
            'row and col cannot contain duplicates',
          ))
        end
      end

      context 'for swap type' do
        before do
          move.move_type = 'swap'
        end

        it do
          expect(subject).to(include('missing arguments for pre-processing'))
        end
        it do
          move.returned_tiles = [100]
          expect(subject).to(include(
            'returned tiles values must be in: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]'
          ))
        end
        it do
          move.returned_tiles = [1, 2, 3, 4, 5, 6, 7, 8]
          expect(subject).to(include('returned tiles size must be less than or equal 7'))
        end
      end

      context 'when game does not exist' do
        before do
          move.move_type = 'tile_placement'
          move.game_id = -1
        end

        it do
          expect(subject).to(include('id -1 does not exist in Game'))
        end
      end

      context 'when game us not owned by user' do
        let(:user2) { create(:user) }
        before do
          move.user = user2
        end

        before do
          move.move_type = 'tile_placement'
        end

        it do
          expect(subject).to(include("Game id #{game.id} does not belong to User #{user2.id}"))
        end
      end
    end
  end
end

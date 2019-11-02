# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PlayLogic::MoveLogic::MoveHelpers) do
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
          expect(subject.errors).to(include(:move_missing_arguments))
        end
      end

      context 'for tile_placement type' do
        before do
          move.move_type = 'tile_placement'
        end

        it do
          expect(subject.errors).to(include(:move_missing_arguments))
        end

        it do
          move.row_num = [1, 2, 3, 4]
          move.col_num = [1, 2, 3, 4]
          move.tile_value = [1, 2, 3, 4]
          expect(subject.errors).to(include(
            :move_input_to_long,
          ))
        end

        it do
          move.row_num = [1]
          move.col_num = [1]
          move.tile_value = [1, 2]
          expect(subject.errors).to(include(:move_input_mismatch))
        end

        it do
          move.row_num = [100]
          move.col_num = [100]
          move.tile_value = [100]
          expect(subject.errors).to(include(
            :move_row_col_invalid,
            :move_tile_value_invalid,
          ))
        end

        it do
          move.row_num = [1, 2, 1]
          move.col_num = [1, 3, 1]
          move.tile_value = [1, 2, 3]
          expect(subject.errors).to(include(
            :move_input_duplicate,
          ))
        end

        it do
          move.row_num = [1, 2, 3]
          move.col_num = [1, 3, 2]
          move.tile_value = [1, 2, 3]
          expect(subject.errors).to(include(
            :move_strightness,
          ))
        end
      end

      context 'for swap type' do
        before do
          move.move_type = 'swap'
        end

        it do
          expect(subject.errors).to(include(:move_missing_arguments))
        end

        it do
          move.returned_tiles = [100]
          expect(subject.errors).to(include(
            :move_tile_value_invalid,
          ))
        end

        it do
          move.returned_tiles = [1, 2, 3, 4, 5, 6, 7, 8]
          expect(subject.errors).to(include(:move_swap_input_to_long))
        end
      end

      context 'when game or user does not exist' do
        before do
          move.move_type = 'tile_placement'
          move.game_id = -1
          move.user_id = -1
        end

        it do
          expect(subject.errors).to(include(:move_user_does_not_exist))
          expect(subject.errors).to(include(:move_game_does_not_exist))
        end
      end

      context 'when game is not owned by user' do
        let(:user2) { create(:user) }
        before do
          move.user = user2
        end

        before do
          move.move_type = 'tile_placement'
        end

        it do
          expect(subject.errors).to(include(:move_user_does_not_own_game))
        end
      end
    end
  end
end

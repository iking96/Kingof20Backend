# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Move, type: :model) do
  it { should validate_presence_of(:type) }

  context 'is tile_placement type' do
    before { allow(subject).to(receive(:tile_placement?).and_return(true)) }
    it { should validate_presence_of(:row_num) }
    it { should validate_presence_of(:col_num) }
    it { should validate_presence_of(:tile_value) }
  end

  context 'is swap type' do
    before { allow(subject).to(receive(:swap?).and_return(true)) }
    it { should validate_presence_of(:returned_tiles) }
  end

  it { should validate_presence_of(:move_number) }
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:game) }

  context 'a move' do
    let(:user) { create(:user) }
    let(:game) do
      create(:game, initiator: user)
    end
    let!(:move) { create(:move, game: game, user: user, type: 'tile_placement') }

    it 'does not allow unrecognized type values' do
      expect { move.type = "some_string" }.to(raise_error ArgumentError)
    end

    context 'tests pre_processing conditions' do
      let(:game) do
        create(:game, initiator: user)
      end

      before do
        subject.game = game
      end

      context 'for tile_placement type' do
        before do
          subject.type = 'tile_placement'
        end

        it do
          subject.valid?
          expect(subject.errors[:base]).to(include('missing arguments for pre-processing'))
          subject.row_num = [1, 2, 3, 4]
          subject.col_num = [1, 2, 3, 4]
          subject.tile_value = [1, 2, 3, 4]
          subject.valid?
          expect(subject.errors.to_h).to(include(
            row_num: 'row input size must be less than or equal 3',
            col_num: 'col input size must be less than or equal 3',
            tile_value: 'tile_value size input must be less than or equal 3',
          ))
          subject.row_num = [1]
          subject.col_num = [1]
          subject.tile_value = [1, 2]
          subject.valid?
          expect(subject.errors[:base]).to(include('row, col and tile_value input must be same length'))
          subject.row_num = [100]
          subject.col_num = [100]
          subject.tile_value = [100]
          subject.valid?
          expect(subject.errors.to_h).to(include(
            row_num: 'row numbers must be in: [0..12]',
            col_num: 'col numbers must be in: [0..12]',
            tile_value: 'tile values must be in: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]',
          ))
        end
      end

      context 'for swap type' do
        before do
          subject.type = 'swap'
        end

        it do
          subject.valid?
          expect(subject.errors[:base]).to(include('missing arguments for pre-processing'))
          subject.returned_tiles = [100]
          subject.valid?
          expect(subject.errors[:returned_tiles]).to(include(
            'returned tiles values must be in: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]'
          ))
          subject.returned_tiles = [1, 2, 3, 4, 5, 6, 7, 8]
          subject.valid?
          expect(subject.errors[:returned_tiles]).to(include('returned tiles size must be less than or equal 7'))
        end
      end

      it do
        subject.game_id = -1
        subject.valid?
        expect(subject.errors[:game]).to(include('id -1 does not exist in Game'))
      end
    end
  end
end

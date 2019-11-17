# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Move, type: :model) do
  it { should validate_presence_of(:move_type) }

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
    let!(:move) { create(:move, game: game, user: user, move_type: 'tile_placement') }

    it 'does not allow unrecognized type values' do
      expect { move.move_type = "some_string" }.to(raise_error ArgumentError)
    end

    context 'tests pre_processing conditions' do
      let(:game) { create(:game_with_user) }

      context 'for tile_placement type' do
        before do
          subject.move_type = 'tile_placement'
          subject.row_num = [1, 2, 3, 4]
          subject.col_num = [1, 2, 3, 4]
          subject.tile_value = [1, 2, 3, 4]
        end

        it do
          subject.valid?(:pre_processing)
          expect(subject.errors[:base]).to(include('move preprocesses returned false'))
        end
      end
    end
  end
end

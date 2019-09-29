# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Game, type: :model) do
  it { should validate_presence_of(:board) }
  it { should validate_presence_of(:initiator_score) }
  it { should validate_presence_of(:initiator_rack) }
  it { should validate_presence_of(:opponent_score) }
  it { should validate_presence_of(:opponent_rack) }
  it { should validate_presence_of(:initiator) }
  it { should validate_presence_of(:current_player) }
  # Complete: using validate_inclusion_of with boolean columns is discuraged
  it { should validate_presence_of(:available_tiles) }

  it 'returns correct tile mappings' do
    expect(Game.available_tiles_string_value(index: 1)).to(eq("1"))
    expect(Game.available_tiles_string_value(index: 13)).to(eq("Over"))
    expect(Game.available_tiles_string_value(index: 14)).to(eq(nil))
  end

  context 'a game' do
    let(:initiating_user) { create(:user) }
    let!(:game) do
      create(:game, initiator: initiating_user)
    end

    it 'does not allow unrecognized current_player values' do
      expect { game.current_player = "some_string" }.to(raise_error ArgumentError)
    end
  end

  context 'when a user is involved in a game' do
    let(:initiating_user) { create(:user) }
    let(:opposing_user) { create(:user) }
    let!(:game) do
      create(:game, initiator: initiating_user)
    end
    let(:user_games) { initiating_user.games }

    it 'is possible to find users involved in game' do
      expect(game.initiator).to(eq(initiating_user))
    end
  end

  context 'when a game has moves' do
    let(:initiating_user) { create(:user) }
    let(:game) do
      create(:game, initiator: initiating_user)
    end
    let!(:move1) { create(:move, game: game, user: initiating_user) }
    let!(:move2) { create(:move, game: game, user: initiating_user) }

    it 'is possible find moves from game' do
      expect(game.moves.size).to(eq(2))
    end
  end
end

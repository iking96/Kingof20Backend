# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Game, type: :model) do
  context 'on creation' do
    let!(:user) { create(:user) }

    context 'when game information is not supplied' do
      it 'fills them in' do
        game = create(
          :game,
          initiator: user,
          board: nil,
          available_tiles: nil,
          initiator_score: nil,
          initiator_rack: nil,
          opponent_score: nil,
          opponent_rack: nil,
          current_player: nil,
        )
        expect(game.board).to(be_a(Array))
        expect(game.initiator_score).to(eq(0))
        expect(game.opponent_score).to(eq(0))
        expect(
          (game.available_tiles +
          game.initiator_rack +
          game.opponent_rack).sort
        ).to(eq(Game.initial_available_tiles.sort))
        expect(game.current_player).to(eq('initiator'))
      end
    end
  end

  it { should validate_presence_of(:initiator) }
  # Complete: using validate_inclusion_of with boolean columns is discouraged

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

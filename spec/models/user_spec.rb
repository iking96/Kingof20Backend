# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(User, type: :model) do
  it { should validate_presence_of(:username) }
  it { should validate_presence_of(:encrypted_password) }
  it { should validate_uniqueness_of(:username) }
  it { should validate_uniqueness_of(:encrypted_password) }

  context 'when the user is involved in a game' do
    let(:initiating_user) { create(:user) }
    let!(:game) do
      create(:game,
      initiator: initiating_user,
      initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
    end
    let(:user_games) { initiating_user.games }
    let(:user_visible_games) { initiating_user.visible_games }

    it 'is possible to find their games' do
      expect(initiating_user.initiated_games.size).to(eq(1))
      expect(initiating_user.opposing_games.size).to(eq(0))
      expect(initiating_user.current_player_games.size).to(eq(1))
      expect(user_visible_games.to_json).to(eq(user_games.to_json))
      expect(user_games.size).to(eq(1))
      expect(user_games.first.initiator_rack).to(eq(
        [7, 6, 5, 4, 3, 2, 1],
      ))
    end

    context 'and the game has moves' do
      let!(:move1) { create(:move, game: game, user: initiating_user, move_type: 'tile_placement') }
      let!(:move2) { create(:move, game: game, user: initiating_user, move_type: 'tile_placement') }

      it 'is possible to find all a players moves' do
        expect(initiating_user.moves.size).to(eq(2))
      end
    end

    context 'which is in a game queue entry' do
      let!(:game_queue_entry) { GameQueueEntry.create!(user: initiating_user, game: game) }

      it 'is possible find a users game queue entries' do
        expect(initiating_user.game_queue_entries.size).to(eq(1))
      end

      it 'is possible find a users waiting games' do
        expect(initiating_user.waiting_games).to(eq([game]))
      end
    end

    context 'and the game has some non-visible state' do
      before do
        game.hidden_from = hidden_from
        game.save!
      end

      context 'the hidden_from_both state' do
        let(:hidden_from) { Game::HIDDEN_FROM_BOTH }

        it 'hides game correctly' do
          expect(user_visible_games.size).to(eq(0))
          expect(user_games.size).to(eq(1))
        end
      end

      context 'the hidden_from_initiator state' do
        let(:hidden_from) { Game::HIDDEN_FROM_INITIATOR }

        it 'hides game correctly' do
          expect(user_visible_games.size).to(eq(0))
          expect(user_games.size).to(eq(1))
        end
      end

      context 'the hidden_from_both state' do
        let(:hidden_from) { Game::HIDDEN_FROM_OPPONENT }

        it 'hides game correctly' do
          expect(user_visible_games.size).to(eq(1))
          expect(user_games.size).to(eq(1))
        end
      end
    end
  end
end

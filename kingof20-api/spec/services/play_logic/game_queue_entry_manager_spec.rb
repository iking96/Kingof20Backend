# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PlayLogic::GameQueueEntryManager) do
  describe 'pair_user' do
    subject { described_class.pair_user(user: user) }

    let!(:user) { create(:user) }

    context 'there are no games in the game queue' do
      it 'returns nil' do
        expect(subject).to(eq(nil))
      end
    end

    context 'there are games in the game queue' do
      let!(:waiting_game) do
        create(:game,
        initiator: user2,
        initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
      end
      let(:user2) { create(:user) }
      let!(:game_queue_entry) { GameQueueEntry.create!(user: user2, game: waiting_game) }

      it 'responds with the waiting game' do
        expect(subject).to(eq(waiting_game))
      end

      it 'removes a game to the game queue' do
        expect { subject }.to(change { GameQueueEntry.count }.by(-1))
      end

      context 'when there are concurrent requests' do
        subject do
          threads = 2.times.map do
            Thread.new do
              described_class.pair_user(user: user)
            end
          end
          threads.each(&:join)
        end

        it 'blocks duplicate requests' do
          expect { subject }.to(change { GameQueueEntry.count }.by(-1))
        end

        context 'when there are multiple waiting games' do
          let!(:waiting_game2) do
            create(:game,
            initiator: user2,
            initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
          end
          let!(:game_queue_entry2) { GameQueueEntry.create!(user: user2, game: waiting_game2) }

          it 'dequeues multiple games' do
            expect { subject }.to(change { GameQueueEntry.count }.by(-2))
          end

          context 'when there are more requests than waiting games' do
            let!(:waiting_game3) do
              create(:game,
              initiator: user2,
              initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
            end
            let!(:game_queue_entry3) { GameQueueEntry.create!(user: user2, game: waiting_game3) }

            it 'blocks duplicate requests' do
              expect { subject }.to(change { GameQueueEntry.count }.by(-2))
            end
          end
        end
      end
    end
  end

  describe 'enqueue_game' do
    subject { described_class.enqueue_game(game: game) }
    let!(:game) do
      create(:game,
      initiator: user,
      initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
    end
    let(:user) { create(:user) }

    it 'adds a game to the game queue' do
      expect { subject }.to(change { GameQueueEntry.count }.by(1))
      expect(GameQueueEntry.first.game).to(eq(game))
    end
  end
end

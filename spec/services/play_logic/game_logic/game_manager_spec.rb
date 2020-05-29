# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PlayLogic::GameLogic::GameManager) do
  describe 'get_user_games_with_params' do
    subject { described_class.get_user_games_with_params(user: requesting_user, params: params) }
    let(:params) { {} }

    context 'when the user has games' do
      let!(:game) do
        create(:game,
          initiator: requesting_user,
          opponent: user2)
      end
      let(:user2) { create(:user) }
      let(:requesting_user) { create(:user) }

      it 'responds with a users games' do
        expect(subject).to(eq(
          [
            game,
          ]
        ))
      end

      context 'when there are other games' do
        let!(:game2) do
          create(:game,
          initiator: user2)
        end

        it 'responds with only a users games' do
          expect(subject).to(eq(
            [
              game,
            ]
          ))
        end

        context 'which the user is a part of' do
          let!(:game2) do
            create(:game,
            initiator: user2,
            opponent: requesting_user)
          end

          it 'responds with a users games' do
            expect(subject).to(eq(
              [
                game,
                game2,
              ]
            ))
          end
        end
      end

      context 'when there are params' do
        let!(:game2) do
          create(:game,
          initiator: user2,
          opponent: requesting_user)
        end

        context 'and its the "initiator" param' do
          let(:params) { { 'initiator' => true } }
          it 'should respond with games where the user is the initiator' do
            expect(subject).to(eq(
              [
                game,
              ]
            ))
          end
        end

        context 'and its the "opponent" param' do
          let(:params) { { 'opponent' => true } }

          it 'should respond with games where the user is the initiator' do
            expect(subject).to(eq(
              [
                game2,
              ]
            ))
          end
        end

        context 'and its the "all" param' do
          let(:params) { { 'all' => true } }

          context 'when a game is not visible to the player invisible' do
            before do
              game.hidden_from = Game::HIDDEN_FROM_INITIATOR
              game.save!
            end

            it 'responds with all a users games' do
              expect(subject.sort).to(eq(
                [
                  game2,
                  game,
                ].sort
              ))
            end
          end
        end
      end

      context 'when a game is not visible to the player invisible' do
        before do
          game.hidden_from = Game::HIDDEN_FROM_INITIATOR
          game.save!
        end

        it 'responds with a users games' do
          expect(subject).to(eq([]))
        end
      end
    end
  end

  describe 'get_user_game' do
    subject { described_class.get_user_game(game_id: game_id, user: requesting_user) }

    context 'when the user has games' do
      let!(:game) do
        create(:game,
          initiator: requesting_user,
          opponent: user2)
      end
      let(:user2) { create(:user) }
      let(:requesting_user) { create(:user) }
      let(:game_id) { game.id }

      it 'responds with a users game' do
        expect(subject).to(eq(game))
      end

      context 'when the game id does not exist' do
        let(:game_id) { -1 }

        it 'responds with an error' do
          expect { subject }.to(raise_error(ActiveRecord::RecordNotFound))
        end
      end

      context 'when the game does not belong to the user' do
        let!(:game) do
          create(:game,
            initiator: user2)
        end

        it 'responds with an error' do
          expect { subject }.to(raise_error(ActiveRecord::RecordNotFound))
        end
      end
    end
  end

  describe 'create_game_or_enqueue_for_user' do
    subject { described_class.create_game_or_enqueue_for_user(user: requesting_user) }
    let(:requesting_user) { create(:user) }

    context 'there are no games in the game queue' do
      it 'creats a new game' do
        expect { subject }.to(change { Game.count }.by(1))
      end

      it 'responds with the new game' do
        expect(subject).to(eq(Game.first))
      end

      it 'adds a game to the game queue' do
        expect { subject }.to(change { GameQueueEntry.count }.by(1))
      end
    end

    context 'there are games in the game queue' do
      let!(:waiting_game) { create(:game_with_user) }
      let!(:game_queue_entry) { GameQueueEntry.create!(user: waiting_game.initiator, game: waiting_game) }

      it 'does not create a new game' do
        expect { subject }.to_not(change { Game.count })
      end

      it 'removes a game to the game queue' do
        expect { subject }.to(change { GameQueueEntry.count }.by(-1))
      end

      it 'responds with the waiting game' do
        expect(subject).to(eq(waiting_game))
      end
    end

    context 'when waiting user and creating user are the same' do
      let!(:waiting_game) do
        create(:game,
        initiator: requesting_user)
      end
      let!(:game_queue_entry) { GameQueueEntry.create!(user: requesting_user, game: waiting_game) }

      it 'creats a new game' do
        expect { subject }.to(change { Game.count }.by(1))
      end

      it 'responds with the new game' do
        expect(subject).to(eq(Game.last))
      end

      it 'adds a game to the game queue' do
        expect { subject }.to(change { GameQueueEntry.count }.by(1))
      end

      context 'when there is another waiting game' do
        let!(:waiting_game2) do
          create(:game,
          initiator: user3)
        end
        let(:user3) { create(:user) }
        let!(:game_queue_entry) { GameQueueEntry.create!(user: user3, game: waiting_game2) }

        it 'does not create a new game' do
          expect { subject }.to_not(change { Game.count })
        end

        it 'removes a game to the game queue' do
          expect { subject }.to(change { GameQueueEntry.count }.by(-1))
        end

        it 'responds with the waiting game' do
          expect(subject).to(eq(waiting_game2))
        end
      end
    end
  end

  describe 'update_game' do
    subject { described_class.update_game(game_id: game_id, user: requesting_user, params: params) }
    let(:params) { {} }

    context 'when the user has games' do
      let!(:game) do
        create(:game,
          initiator: initiating_user,
          opponent: opposing_user)
      end
      let(:requesting_user) { create(:user) }
      let(:initiating_user) { requesting_user }
      let(:opposing_user) { nil }
      let(:game_id) { game.id }

      it 'responds with a users game' do
        expect(subject).to(eq(game))
      end

      context 'when the game is to be forfited' do
        let(:params) { { 'forfit' => true } }

        it 'forfits the correct user' do
          subject
          game.reload
          expect(game.stage).to(eq('initiator_forfit'))
        end

        context 'when the user is the opponent' do
          let(:initiating_user) { create(:user) }
          let(:opposing_user) { requesting_user }

          it 'forfits the correct user' do
            subject
            game.reload
            expect(game.stage).to(eq('opponent_forfit'))
          end
        end
      end
    end
  end

  describe 'delete_user_game' do
    subject { described_class.delete_user_game(game_id: game_id, user: requesting_user) }

    context 'when the user has games' do
      let!(:game) do
        create(:game,
          initiator: owning_user)
      end
      let(:owning_user) { requesting_user }
      let(:requesting_user) { create(:user) }
      let(:game_id) { game.id }

      it 'responds with a users game' do
        expect(subject).to(eq(game))
      end

      it 'make the deleted game no longer visible' do
        expect { subject }.to(change { owning_user.visible_games.count }.by(-1))
      end

      context 'when the game as a game queue entry' do
        let!(:game_queue_entry) { GameQueueEntry.create!(user: owning_user, game: game) }

        it 'deletes all connected game queue entries' do
          expect { subject }.to(change(GameQueueEntry, :count).by(-1))
        end
      end

      context 'when the game id does not exist' do
        let(:game_id) { -1 }

        it 'responds with an error' do
          expect { subject }.to(raise_error(ActiveRecord::RecordNotFound))
        end
      end

      context 'when the game does not belong to the user' do
        let(:user2) { create(:user) }
        let(:owning_user) { user2 }

        it 'responds with an error' do
          expect { subject }.to(raise_error(ActiveRecord::RecordNotFound))
        end
      end
    end
  end
end

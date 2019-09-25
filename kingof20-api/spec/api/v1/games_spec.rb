# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Game API', type: :request) do
  let(:token) { double acceptable?: true }
  let(:user) { create(:user) }

  before do
    stub_access_token(token)
    stub_current_user(user)
  end

  describe 'GET /api/games' do
    subject { get '/api/games' }

    context 'when the user has games' do
      let!(:game) do
        create(:game,
        initiator: user,
        current_player: user,
        initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
      end

      it 'responds with a users games' do
        subject
        expect(response).to(have_http_status(200))
        expect(json.size).to(eq(1))
        expect(json.first).to(include(
          "initiator_rack" => [7, 6, 5, 4, 3, 2, 1],
          "initiator_id" => user.id,
          "opponent_id" => nil,
        ))
      end

      context 'when there are other games' do
        let(:user2) { create(:user) }
        let!(:game2) do
          create(:game,
          initiator: user2,
          current_player: user2,
          initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
        end

        it 'should respond with unauthorized' do
          subject
          expect(response).to(have_http_status(200))
          expect(json.size).to(eq(1))
          expect(json.first).to(include(
            "initiator_rack" => [7, 6, 5, 4, 3, 2, 1],
            "initiator_id" => user.id,
            "opponent_id" => nil,
          ))
        end
      end
    end
  end

  describe 'GET /api/games/$id' do
    subject { get "/api/games/#{game_id}" }

    context 'when the user has games' do
      let!(:game) do
        create(:game,
        initiator: user,
        current_player: user,
        initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
      end
      let(:game_id) { game.id }

      it 'responds with a users games' do
        subject
        expect(response).to(have_http_status(200))
        expect(json).to(include(
          "initiator_rack" => [7, 6, 5, 4, 3, 2, 1],
          "initiator_id" => user.id,
          "opponent_id" => nil,
        ))
      end

      context 'when the game id does not exist' do
        let(:game_id) { -1 }

        it 'responds with a users games' do
          subject
          expect(response).to(have_http_status(200))
          expect(json).to(include(
            "initiator_rack" => [7, 6, 5, 4, 3, 2, 1],
            "initiator_id" => user.id,
            "opponent_id" => nil,
          ))
        end
      end
    end
  end

  describe 'POST /api/games' do
    subject { post '/api/games' }

    context 'there are no games in the game queue' do
      it 'responds with a new game' do
        subject
        expect(response).to(have_http_status(200))
        expect(json).to(include(
          "initiator_id" => user.id,
          "opponent_id" => nil,
        ))
        expect(
          (json["initiator_rack"] +
          json["opponent_rack"] +
          json["available_tiles"]).sort
        ).to(eq(
          Game.initial_available_tiles.sort
        ))
        expect(json["complete"]).to(eq(false))
      end

      it 'adds a game to the game queue' do
        expect { subject }.to(change { GameQueueEntry.count }.by(1))
      end
    end

    context 'there are games in the game queue' do
      let!(:waiting_game) do
        create(:game,
        initiator: user2,
        current_player: user,
        initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
      end
      let(:user2) { create(:user) }
      let!(:game_queue_entry) { GameQueueEntry.create!(user: user2, game: waiting_game) }

      it 'responds with the waiting game' do
        subject
        expect(response).to(have_http_status(200))
        expect(json).to(include(
          "initiator_id" => user2.id,
          "opponent_id" => user.id,
        ))
        expect(json["complete"]).to(eq(false))
      end

      it 'removes a game to the game queue' do
        expect { subject }.to(change { GameQueueEntry.count }.by(-1))
      end

      context 'when waiting user and creating user are the same' do
        let(:user2) { user }

        it 'responds with a new game' do
          subject
          expect(response).to(have_http_status(200))
          expect(json).to(include(
            "initiator_id" => user.id,
            "opponent_id" => nil,
          ))
          expect(
            (json["initiator_rack"] +
            json["opponent_rack"] +
            json["available_tiles"]).sort
          ).to(eq(
            Game.initial_available_tiles.sort
          ))
          expect(json["complete"]).to(eq(false))
        end

        it 'adds a game to the game queue' do
          expect { subject }.to(change { GameQueueEntry.count }.by(1))
        end

        context 'when there is another waiting game' do
          let!(:waiting_game2) do
            create(:game,
            initiator: user3,
            current_player: user,
            initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
          end
          let(:user3) { create(:user) }
          let!(:game_queue_entry) { GameQueueEntry.create!(user: user3, game: waiting_game2) }

          it 'should respond with the waiting game' do
            subject
            expect(response).to(have_http_status(200))
            expect(json).to(include(
              "initiator_id" => user3.id,
              "opponent_id" => user.id,
            ))
            expect(json["complete"]).to(eq(false))
          end

          it 'removes a game to the game queue' do
            expect { subject }.to(change { GameQueueEntry.count }.by(-1))
          end
        end
      end
    end
  end
end

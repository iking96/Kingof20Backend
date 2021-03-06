# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Game API', type: :request) do
  let(:token) { double acceptable?: true }
  let(:user) { create(:user) }

  before do
    stub_access_token(token)
    stub_current_user(user)
  end

  describe 'GET /api/v1/games' do
    subject { get '/api/v1/games', params: params }
    let(:params) { "" }

    context 'when the user has games' do
      let!(:game) do
        create(:game,
        initiator: user,
        initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
      end

      it 'responds with a users games' do
        subject
        expect(response).to(have_http_status(200))
        expect(response.headers['X-total-count']).to(eq(1))
        expect(json['games'].size).to(eq(1))
        expect(json['games'].first).to(include(
          "your_rack" => [7, 6, 5, 4, 3, 2, 1],
          "you" => hash_including('id' => user.id),
          "them" => nil,
        ))
      end

      context 'when there are other games' do
        let(:user2) { create(:user) }
        let!(:game2) do
          create(:game,
          initiator: user2,
          initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
        end

        it 'responds with only a users games' do
          subject
          expect(response).to(have_http_status(200))
          expect(json['games'].size).to(eq(1))
          expect(json['games'].first).to(include(
            "your_rack" => [7, 6, 5, 4, 3, 2, 1],
            "you" => hash_including('id' => user.id),
            "them" => nil,
          ))
        end

        context 'which the user is a part of' do
          let!(:game2) do
            create(:game,
              initiator: user2,
              opponent: user,
              initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
          end

          it 'responds with a users games' do
            subject
            expect(response).to(have_http_status(200))
            expect(json['games'].size).to(eq(2))
            expect(json['games'].last).to(include(
              "your_rack" => [1, 2, 3, 4, 5, 6, 11],
              "you" => hash_including('id' => user.id),
              "them" => hash_including('id' => user2.id),
            ))
          end
        end
      end

      context 'when there are params' do
        let(:user2) { create(:user) }
        let!(:game2) do
          create(:game,
            initiator: user2,
            opponent: user,
            initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
        end

        context 'and its the "initiator" param' do
          let(:params) { { initiator: true } }
          it 'should respond with games where the user is the initiator' do
            subject
            expect(json['games'].first).to(include(
              "your_rack" => [7, 6, 5, 4, 3, 2, 1],
              "you" => hash_including('id' => user.id),
              "them" => nil,
            ))
          end
        end

        context 'and its the "opponent" param' do
          let(:params) { { opponent: true } }

          it 'should respond with games where the user is the initiator' do
            subject
            expect(json['games'].first).to(include(
              "your_rack" => [1, 2, 3, 4, 5, 6, 11],
              "you" => hash_including('id' => user.id),
              "them" => hash_including('id' => user2.id),
            ))
          end
        end
      end
    end
  end

  describe 'GET /api/v1/games/$id' do
    subject { get "/api/v1/games/#{game_id}" }

    context 'when the user has games' do
      let!(:game) do
        create(:game,
        initiator: owning_user,
        initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
      end
      let(:game_id) { game.id }
      let(:owning_user) { user }

      it 'responds with a users games' do
        subject
        expect(response).to(have_http_status(200))
        expect(json['game']).to(include(
          "your_rack" => [7, 6, 5, 4, 3, 2, 1],
          "you" => hash_including('id' => user.id),
          "them" => nil,
        ))
      end

      context 'when the game id does not exist' do
        let(:game_id) { -1 }

        it 'responds with an error' do
          subject
          expect(response).to(have_http_status(404))
          expect(json).to(include(
            "error" => "record_not_found",
            "status" => 404,
          ))
          expect(json["message"]).to(include("Couldn't find Game"))
        end
      end

      context 'when the game does not belong to the user' do
        let(:user2) { create(:user) }
        let(:owning_user) { user2 }

        it 'responds with an error' do
          subject
          expect(response).to(have_http_status(404))
          expect(json).to(include(
            "error" => "record_not_found",
            "status" => 404,
          ))
          expect(json["message"]).to(include("Couldn't find Game"))
        end
      end
    end
  end

  describe 'POST /api/v1/games' do
    subject { post '/api/v1/games' }

    context 'there are no games in the game queue' do
      it 'responds with a new game' do
        subject
        expect(response).to(have_http_status(200))
        expect(json['game']).to(include(
          "you" => hash_including('id' => user.id),
          "them" => nil,
        ))
        expect(json['game']["complete"]).to(eq(false))
      end

      it 'adds a game to the game queue' do
        expect { subject }.to(change { GameQueueEntry.count }.by(1))
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
        subject
        expect(response).to(have_http_status(200))
        expect(json['game']).to(include(
          "you" => hash_including('id' => user.id),
          "them" => hash_including('id' => user2.id),
        ))
        expect(json['game']["complete"]).to(eq(false))
      end

      it 'removes a game to the game queue' do
        expect { subject }.to(change { GameQueueEntry.count }.by(-1))
      end

      context 'when waiting user and creating user are the same' do
        let(:user2) { user }

        it 'responds with a new game' do
          subject
          expect(response).to(have_http_status(200))
          expect(json['game']).to(include(
            "you" => hash_including('id' => user.id),
            "them" => nil,
          ))
          expect(json['game']["complete"]).to(eq(false))
        end

        it 'adds a game to the game queue' do
          expect { subject }.to(change { GameQueueEntry.count }.by(1))
        end

        context 'when there is another waiting game' do
          let!(:waiting_game2) do
            create(:game,
            initiator: user3,
            initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
          end
          let(:user3) { create(:user) }
          let!(:game_queue_entry) { GameQueueEntry.create!(user: user3, game: waiting_game2) }

          it 'should respond with the waiting game' do
            subject
            expect(response).to(have_http_status(200))
            expect(json['game']).to(include(
              "you" => hash_including('id' => user.id),
              "them" => hash_including('id' => user3.id),
            ))
            expect(json['game']["complete"]).to(eq(false))
          end

          it 'removes a game to the game queue' do
            expect { subject }.to(change { GameQueueEntry.count }.by(-1))
          end
        end
      end
    end
  end

  describe 'PATCH /api/v1/games/$id' do
    subject { patch "/api/v1/games/#{game_id}", params: params }
    let(:params) { nil }

    context 'when the user has games' do
      let!(:game) do
        create(:game,
        initiator: owning_user,
        initiator_rack: [7, 6, 5, 4, 3, 2, 1],
        opponent: opposing_user,)
      end
      let(:game_id) { game.id }
      let(:owning_user) { user }
      let(:opposing_user) { nil }

      it 'responds with a users games' do
        subject
        expect(response).to(have_http_status(200))
        expect(json['game']).to(include(
          "your_rack" => [7, 6, 5, 4, 3, 2, 1],
          "you" => hash_including('id' => user.id),
          "them" => nil,
        ))
      end

      context 'when the game is to be forfited' do
        let(:params) { { forfit: true } }

        it 'forfits the correct user' do
          subject
          expect(response).to(have_http_status(200))
          expect(json['game']).to(include(
            "complete" => true,
          ))
        end

        context 'when the user is the opponent' do
          let(:owning_user) { create(:user) }
          let(:opposing_user) { user }

          it 'forfits the correct user' do
            subject
            expect(response).to(have_http_status(200))
            expect(json['game']).to(include(
              "complete" => true,
            ))
          end
        end
      end
    end
  end

  describe 'DELETE /api/v1/games/$id' do
    subject { delete "/api/v1/games/#{game_id}" }

    context 'when the user has games' do
      let!(:game) do
        create(:game,
        initiator: owning_user,
        initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
      end
      let(:game_id) { game.id }
      let(:owning_user) { user }

      it 'responds with a users games' do
        subject
        expect(response).to(have_http_status(200))
        expect(json['game']).to(include(
          "your_rack" => [7, 6, 5, 4, 3, 2, 1],
          "you" => hash_including('id' => user.id),
          "them" => nil,
        ))
      end

      it 'make the deleted game no longer visible' do
        expect { subject }.to(change { owning_user.visible_games.count }.by(-1))
      end

      context 'when the game id does not exist' do
        let(:game_id) { -1 }

        it 'responds with an error' do
          subject
          expect(response).to(have_http_status(404))
          expect(json).to(include(
            "error" => "record_not_found",
            "status" => 404,
          ))
          expect(json["message"]).to(include("Couldn't find Game"))
        end
      end

      context 'when the game does not belong to the user' do
        let(:user2) { create(:user) }
        let(:owning_user) { user2 }

        it 'responds with an error' do
          subject
          expect(response).to(have_http_status(404))
          expect(json).to(include(
            "error" => "record_not_found",
            "status" => 404,
          ))
          expect(json["message"]).to(include("Couldn't find Game"))
        end
      end
    end
  end

  # describe 'PUT /api/games/$id' do
  # end
end

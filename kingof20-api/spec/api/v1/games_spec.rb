require 'rails_helper'

RSpec.describe Api::V1::GamesController do
  let(:token) { double acceptable?: true }
  let(:user) { create(:user) }

  before do
    stub_access_token(token)
    stub_current_user(user)
  end

  describe 'GET /api/games' do

    subject { get '/api/games' }

    it 'should respond with unauthorized' do
      subject
      expect(response).to have_http_status(200)
    end

    context 'when the user has games' do
      let!(:game) { create(:game,
        initiator: user,
        current_player: user,
        initiator_rack: [7,6,5,4,3,2,1],
        )
      }

      it 'should respond with unauthorized' do
        subject
        expect(response).to have_http_status(200)
        expect(json.size).to eq(1)
        expect(json.first).to include(
          "initiator_rack" => [7,6,5,4,3,2,1],
          "initiator_id" => user.id,
          "opponent_id" => nil,
        )
      end

      context 'when there are other games' do
        let(:user2) { create(:user) }
        let!(:game2) { create(:game,
          initiator: user2,
          current_player: user2,
          initiator_rack: [7,6,5,4,3,2,1],
          )
        }

        it 'should respond with unauthorized' do
          subject
          expect(response).to have_http_status(200)
          expect(json.size).to eq(1)
          expect(json.first).to include(
            "initiator_rack" => [7,6,5,4,3,2,1],
            "initiator_id" => user.id,
            "opponent_id" => nil,
          )
        end
      end
    end
  end
end

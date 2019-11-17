# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Move API', type: :request) do
  let(:token) { double acceptable?: true }
  let(:user) { create(:user) }

  before do
    stub_access_token(token)
    stub_current_user(user)
  end

  describe 'GET /api/moves' do
    subject { get '/api/moves', params: params }
    let(:params) { nil }

    context 'when the user has moves' do
      let!(:move) { create(:move, user: owning_user) }
      let!(:move2) { create(:move, user: owning_user) }
      let(:owning_user) { user }

      it 'responds with a users moves' do
        subject
        expect(response).to(have_http_status(200))
        expect(json.first).to(include(
          "user_id" => user.id,
        ))
        expect(json.second).to(include(
          "user_id" => user.id,
        ))
      end

      context 'when there are other moves' do
        let(:user2) { create(:user) }
        let!(:move3) do
          create(
            :move,
            user: user2,
          )
        end

        it 'responds with only a users games' do
          subject
          expect(response).to(have_http_status(200))
          expect(json.first).to(include(
            "user_id" => user.id,
          ))
          expect(json.second).to(include(
            "user_id" => user.id,
          ))
        end
      end

      context 'when there are params' do
        context 'and its the "result" param' do
          let!(:move) { create(:move, user: owning_user, result: move_result) }
          let!(:move2) { create(:move, user: owning_user, result: move2_result) }

          let(:move_result) { 20 }
          let(:move2_result) { 20 }
          let(:search_result) { 20 }

          let(:params) { { result: search_result } }

          it 'responds with moves which match the result' do
            subject
            expect(response).to(have_http_status(200))
            expect(json.first).to(include(
              "user_id" => user.id,
            ))
            expect(json.second).to(include(
              "user_id" => user.id,
            ))
          end

          context 'the search returns does not match any moves' do
            let(:search_result) { 19 }

            it 'responds with moves which match the result' do
              subject
              expect(response).to(have_http_status(200))
              expect(json).to(be_empty)
            end
          end
        end
      end
    end
  end

  describe 'GET /api/moves/$id' do
    subject { get "/api/moves/#{move_id}" }

    context 'when the user has moves' do
      let!(:move) do
        create(
          :move,
          user: owning_user,
        )
      end
      let(:move_id) { move.id }
      let(:owning_user) { user }

      it 'responds with a users moves' do
        subject
        expect(response).to(have_http_status(200))
        expect(json).to(include(
          "user_id" => user.id,
        ))
      end

      context 'when the move id does not exist' do
        let(:move_id) { -1 }

        it 'responds with an error' do
          subject
          expect(response).to(have_http_status(404))
          expect(json).to(include(
            "error" => "record_not_found",
            "status" => 404,
          ))
          expect(json["message"]).to(include("Couldn't find Move"))
        end
      end

      context 'when the move does not belong to the user' do
        let(:user2) { create(:user) }
        let(:owning_user) { user2 }

        it 'responds with an error' do
          subject
          expect(response).to(have_http_status(404))
          expect(json).to(include(
            "error" => "record_not_found",
            "status" => 404,
          ))
          expect(json["message"]).to(include("Couldn't find Move"))
        end
      end
    end
  end

  describe 'POST /api/moves' do
    subject { post '/api/moves', params: params }

    let!(:game) do
      create(
        :game_with_user,
        :with_first_move,
        opponent: opponent,
        initiator_rack: rack,
      )
    end

    let(:user) { game.initiator }
    let(:rack) { [1, 2, 3, 4, 5, 6, 11] }
    let(:opponent) { create(:user) }

    let(:game_url_query) { "move_info[game_id]=#{game_id}" }
    let(:game_id) { game.id }
    let(:row_num) { [1, 3] }
    let(:col_num) { [3, 3] }
    let(:tile_value) { [5, 4] }

    let(:move_info_data) do
      {
        game_id: game_id,
        row_num: row_num,
        col_num: col_num,
        tile_value: tile_value,
        move_type: 'tile_placement',
      }
    end

    let(:params) { { move_info: move_info_data } }

    context 'when the required move_info param is missing' do
      let(:params) { {} }

      it 'responds with an error' do
        subject
        expect(response).to(have_http_status(500))
        expect(json).to(include(
          "error" => "standard_error",
          "status" => 500,
        ))
        expect(json["message"]).to(include("param is missing or the value is empty: move_info"))
      end
    end

    context 'when move_info param is not correct' do
      let(:params) { { move_info: { dummy: 'temp' } } }

      it 'responds with an error' do
        subject
        expect(response).to(have_http_status(422))
        expect(json).to(include(
          "error" => "unprocessable_entity",
          "error_code" => "move_missing_arguments",
          "status" => 422,
        ))
        expect(json["message"]).to(include("missing arguments for pre-processing"))
      end
    end

    context 'when move_info fails pre_processing' do
      let(:row_num) { [1] }

      it 'responds with an error' do
        subject
        expect(response).to(have_http_status(422))
        expect(json).to(include(
          "error" => "unprocessable_entity",
          "error_code" => "move_input_mismatch",
          "status" => 422,
        ))
        expect(json["message"]).to(include("row, col and tile_value input must be same length"))
      end
    end

    context 'when current user is not current player' do
      let(:user) { opponent }

      it 'responds with an error' do
        subject
        expect(response).to(have_http_status(422))
        expect(json).to(include(
          "error" => "unprocessable_entity",
          "error_code" => "move_not_current_player",
          "status" => 422,
        ))
        expect(json["message"]).to(include("User is not current player"))
      end
    end

    context 'when the game rack cannot provide the required tiles' do
      let(:rack) { [1, 1, 1, 1, 1, 1, 11] }

      it 'responds with an error' do
        subject
        expect(response).to(have_http_status(422))
        expect(json).to(include(
          "error" => "unprocessable_entity",
          "error_code" => "game_tiles_not_on_rack",
          "status" => 422,
        ))
        expect(json["message"]).to(include("tiles to remove not all in rack"))
      end
    end

    context 'when the move is invalid' do
      context 'due to its interaction with placed tiles' do
        let(:row_num) { [1] }
        let(:col_num) { [2] }
        let(:tile_value) { [5] }

        it 'responds with an error' do
          subject
          expect(response).to(have_http_status(422))
          expect(json).to(include(
            "error" => "unprocessable_entity",
            "error_code" => "move_creates_double_digit",
            "status" => 422,
          ))
          expect(json["message"]).to(include("move on board created double digit"))
        end
      end

      context 'due to its effect on the game-state' do
        let(:row_num) { [1] }
        let(:col_num) { [1] }
        let(:tile_value) { [5] }

        it 'responds with an error' do
          subject
          expect(response).to(have_http_status(422))
          expect(json).to(include(
            "error" => "unprocessable_entity",
            "error_code" => "game_board_contains_islands",
            "status" => 422,
          ))
          expect(json["message"]).to(include("game board contains islands"))
        end
      end
    end
  end
  #
  # describe 'DELETE /api/games/$id' do
  #   subject { delete "/api/games/#{game_id}" }
  #
  #   context 'when the user has games' do
  #     let!(:game) do
  #       create(:game,
  #       initiator: owning_user,
  #       initiator_rack: [7, 6, 5, 4, 3, 2, 1],)
  #     end
  #     let(:game_id) { game.id }
  #     let(:owning_user) { user }
  #
  #     it 'responds with a users games' do
  #       subject
  #       expect(response).to(have_http_status(200))
  #       expect(json).to(include(
  #         "initiator_rack" => [7, 6, 5, 4, 3, 2, 1],
  #         "initiator_id" => user.id,
  #         "opponent_id" => nil,
  #       ))
  #     end
  #
  #     it 'removes a the game' do
  #       expect { subject }.to(change { Game.count }.by(-1))
  #     end
  #
  #     context 'when the game id does not exist' do
  #       let(:game_id) { -1 }
  #
  #       it 'responds with an error' do
  #         subject
  #         expect(response).to(have_http_status(404))
  #         expect(json).to(include(
  #           "error" => "record_not_found",
  #           "status" => 404,
  #         ))
  #         expect(json["message"]).to(include("Couldn't find Game"))
  #       end
  #     end
  #
  #     context 'when the game does not belong to the user' do
  #       let(:user2) { create(:user) }
  #       let(:owning_user) { user2 }
  #
  #       it 'responds with an error' do
  #         subject
  #         expect(response).to(have_http_status(404))
  #         expect(json).to(include(
  #           "error" => "record_not_found",
  #           "status" => 404,
  #         ))
  #         expect(json["message"]).to(include("Couldn't find Game"))
  #       end
  #     end
  #   end
  # end

  # describe 'PATCH /api/games/$id' do
  # end
  #
  # describe 'PUT /api/games/$id' do
  # end
end

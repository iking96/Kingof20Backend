# frozen_string_literal: true

require 'rails_helper'

RSpec.describe('Move API', type: :request) do
  let(:token) { double acceptable?: true }
  let(:user) { create(:user) }

  before do
    stub_access_token(token)
    stub_current_user(user)
  end

  describe 'GET /api/v1/moves' do
    subject { get '/api/v1/moves', params: params }
    let(:params) { nil }

    context 'when the user has moves' do
      let!(:move) { create(:move, user: owning_user) }
      let!(:move2) { create(:move, user: owning_user) }
      let(:owning_user) { user }

      it 'responds with a users moves' do
        subject
        expect(response).to(have_http_status(200))
        expect(response.headers['X-total-count']).to(eq(2))
        expect(json.first).to(include(
          "username" => user.username,
        ))
        expect(json.second).to(include(
          "username" => user.username,
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
            "username" => user.username,
          ))
          expect(json.second).to(include(
            "username" => user.username,
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
              "username" => user.username,
            ))
            expect(json.second).to(include(
              "username" => user.username,
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

  describe 'GET /api/v1/moves/$id' do
    subject { get "/api/v1/moves/#{move_id}" }

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
          "username" => user.username,
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

  describe 'POST /api/v1/moves' do
    subject { post '/api/v1/moves', params: params }

    let!(:game) do
      create(
        :game_with_user,
        :with_first_move,
        opponent: opponent,
        opponent_rack: rack,
      )
    end

    let(:user) { game.opponent }
    let(:rack) { [1, 2, 3, 4, 5, 6, 11] }
    let(:opponent) { create(:user) }

    let(:game_id) { game.id }
    let(:row_num) { [1, 3] }
    let(:col_num) { [3, 3] }
    let(:tile_value) { [6, 4] }

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

    it 'responds with the new moves' do
      subject
      expect(response).to(have_http_status(200))
      expect(json).to(include(
        "username" => user.username,
        "game_id" => game_id,
        "row_num" => row_num,
        "col_num" => col_num,
        "tile_value" => tile_value,
        "result" => 4
      ))
    end

    context 'when the required move_info param is missing' do
      let(:params) { {} }

      it 'responds with an error' do
        subject
        expect(response).to(have_http_status(500))
        expect(json).to(include(
          "error" => "standard_error",
          "status" => 500,
        ))
        expect(json["message"]).to(include("param is missing or the value is empty or invalid: move_info"))
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
        expect(json["message"]).to(include("Move is missing required information"))
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
        expect(json["message"]).to(include("Invalid move data"))
      end
    end

    context 'when current user is not current player' do
      let(:user) { game.initiator }

      it 'responds with an error' do
        subject
        expect(response).to(have_http_status(422))
        expect(json).to(include(
          "error" => "unprocessable_entity",
          "error_code" => "move_not_current_player",
          "status" => 422,
        ))
        expect(json["message"]).to(include("It's not your turn"))
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
        expect(json["message"]).to(include("Those tiles are not in your rack"))
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
          expect(json["message"]).to(include("Tiles cannot form a two-digit numbers"))
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
          expect(json["message"]).to(include("Tiles must connect to existing tiles on the board"))
        end
      end
    end

    context 'the game is in the end-game' do
      before do
        game.available_tiles = []
        game.save!
      end

      it 'responds with the new moves' do
        subject
        expect(response).to(have_http_status(200))
        expect(json).to(include(
          "username" => user.username,
          "game_id" => game_id,
          "row_num" => row_num,
          "col_num" => col_num,
          "tile_value" => tile_value,
          "result" => 4
        ))
      end

      it 'moves the game to the next stage' do
        subject
        game.reload
        expect(game.stage).to(eq('end_round_two'))
      end

      context 'and it is the initiators turn' do
        let!(:game) { create(:game_with_user) }
        let(:user) { game.initiator }
        let(:row_num) { [2, 2, 2] }
        let(:col_num) { [3, 4, 5] }
        let(:tile_value) { [4, 11, 5] }

        it 'responds with the new moves' do
          subject
          expect(response).to(have_http_status(200))
          expect(json).to(include(
            "username" => user.username,
            "game_id" => game_id,
            "row_num" => row_num,
            "col_num" => col_num,
            "tile_value" => tile_value,
            "result" => 0
          ))
        end

        it 'moves the game to the next stage' do
          subject
          game.reload
          expect(game.stage).to(eq('end_round_one'))
        end
      end
    end
  end
end

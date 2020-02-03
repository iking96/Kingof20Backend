# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PlayLogic::MoveLogic::MoveManager) do
  describe 'get_user_moves_with_params' do
    it "Tests are covered by Move controller; would be nice to add test here though."
  end

  describe 'get_user_move' do
    it "Tests are covered by Move controller; would be nice to add test here though."
  end

  describe 'create_move_and_update_game' do
    subject { described_class.create_move_and_update_game(user: move_user, move_info: move_info) }

    let!(:game) do
      create(
        :game_with_user,
        :with_first_move,
        opponent: opponent_user,
        initiator_rack: [1, 2, 3, 4, 5, 6, 11],
        stage: stage,
      )
    end
    let(:stage) { 'in_play' }

    let(:initiator_user) { game.initiator }
    let(:opponent_user) { create(:user) }
    let(:move_user) { opponent_user }

    let(:move_info) do
      {
        game_id: game.id,
        user_id: move_user.id,
        move_type: move_type,
        row_num: row_num,
        col_num: col_num,
        tile_value: tile_value,
        returned_tiles: returned_tiles,
      }
    end

    let(:row_num) { [] }
    let(:col_num) { [] }
    let(:tile_value) { [] }
    let(:returned_tiles) { [] }

    RSpec.shared_examples('it does not post move to complete game') do
      context 'the game is already complete' do
        context 'in the complete state' do
          let(:stage) { 'complete' }

          it 'raises an error' do
            expect { subject }.to(raise_error(Error::Game::ProcessingError, 'move cannot be posted to complete game'))
          end
        end

        context 'in the initiator_forfit state' do
          let(:stage) { 'initiator_forfit' }

          it 'raises an error' do
            expect { subject }.to(raise_error(Error::Game::ProcessingError, 'move cannot be posted to complete game'))
          end
        end

        context 'in the opponent_forfit state' do
          let(:stage) { 'opponent_forfit' }

          it 'raises an error' do
            expect { subject }.to(raise_error(Error::Game::ProcessingError, 'move cannot be posted to complete game'))
          end
        end
      end
    end

    RSpec.shared_examples('it must be the users turn') do
      let(:move_user) { initiator_user }

      it 'raises an error' do
        expect { subject }.to(raise_error(Error::Move::ProcessingError, 'User is not current player'))
      end
    end

    RSpec.shared_examples('there must be move_info') do
      let(:move_info) { {} }

      it 'raises an error' do
        expect { subject }.to(raise_error Error::Move::PreProcessingError)
      end
    end

    context 'for a tile placement move' do
      let(:move_type) { :tile_placement }
      let(:row_num) { [1, 3] }
      let(:col_num) { [3, 3] }
      let(:tile_value) { [3, 6] }
      let(:expected_board) do
        [
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 5, 11, 4, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        ]
      end
      let(:expected_opponent_rack) { [1, 2, 4, 5, 11] }

      it 'returns the created move' do
        new_move = subject
        expect(new_move).to(be_a(Move))
        expect(new_move.user).to(eq(opponent_user))
        expect(new_move.game).to(eq(game))
        expect(new_move.row_num).to(eq(row_num))
        expect(new_move.col_num).to(eq(col_num))
        expect(new_move.tile_value).to(eq(tile_value))
        expect(new_move.result).to(eq(2))
        expect(new_move.move_number).to(eq(2))
      end

      it 'updates the game appropriately' do
        expect do
          subject
          game.reload
        end.to(
          change { game.moves.count }.by(1)
          .and(change { game.available_tiles.count }.by(-2))
        )
        expect(game.board).to(eq(expected_board))
        expect(game.initiator_score).to(eq(0))
        expect(game.opponent_rack).to(include(*expected_opponent_rack))
        expect(game.opponent_score).to(eq(2))
        expect(game.current_player).to(eq('initiator'))
        expect(game.stage).to(eq('in_play'))
      end

      it_behaves_like 'it does not post move to complete game'

      it_behaves_like 'it must be the users turn'

      it_behaves_like 'there must be move_info'

      context 'the move uses last available tiles' do
        before do
          game.available_tiles = [1, 2]
          game.save!
        end

        it 'moves the game to end_round_one' do
          subject
          game.reload
          expect(game.stage).to(eq('end_round_one'))
        end
      end

      context 'the game is in the end-game' do
        before do
          game.available_tiles = []
          game.save!
        end

        it 'moves the game to end_round_one' do
          subject
          game.reload
          expect(game.stage).to(eq('end_round_one'))
        end

        context 'and it is the initiators turn' do
          let!(:game) { create(:game_with_user) }
          let(:move_user) { initiator_user }
          let(:row_num) { [2, 2, 2] }
          let(:col_num) { [3, 4, 5] }
          let(:tile_value) { [4, 11, 5] }

          it 'moves the game to end_round_one' do
            subject
            game.reload
            expect(game.stage).to(eq('end_round_one'))
          end
        end

        context 'and it is in the end_round_one stage and it is the opponents turn' do
          before do
            game.stage = 'end_round_one'
            game.save!
          end

          it 'moves the game to end_round_two' do
            subject
            game.reload
            expect(game.stage).to(eq('end_round_two'))
          end

          context 'and it is the initiators turn' do
            let!(:game) { create(:game_with_user) }
            let(:move_user) { initiator_user }
            let(:row_num) { [2, 2, 2] }
            let(:col_num) { [3, 4, 5] }
            let(:tile_value) { [4, 11, 5] }

            it 'does not move the game to end_round_two' do
              subject
              game.reload
              expect(game.stage).to(eq('end_round_one'))
            end
          end
        end

        context 'and it is in the end_round_two stage and it is the opponents turn' do
          before do
            game.stage = 'end_round_two'
            game.save!
          end

          it 'moves the game to complete' do
            subject
            game.reload
            expect(game.stage).to(eq('complete'))
          end

          context 'and it is the initiators turn' do
            let!(:game) { create(:game_with_user) }
            let(:move_user) { initiator_user }
            let(:row_num) { [2, 2, 2] }
            let(:col_num) { [3, 4, 5] }
            let(:tile_value) { [4, 11, 5] }

            it 'does not move the game to complete' do
              subject
              game.reload
              expect(game.stage).to(eq('end_round_two'))
            end
          end
        end
      end

      context 'move_info is invalid' do
        let(:row_num) { [1, 2, 20] }
        let(:col_num) { [1, 2, 20] }
        let(:tile_value) { [1, 2, 20] }

        it 'raises an error' do
          expect { subject }.to(raise_error Error::Move::PreProcessingError)
        end
      end

      context 'the rack cannot supply the tiles' do
        let(:tile_value) { [4, 10] }

        it 'raises an error' do
          expect { subject }.to(raise_error(Error::Game::ProcessingError, /not all in rack/))
        end
      end

      context 'move space is taken' do
        let(:row_num) { [2] }
        let(:col_num) { [2] }
        let(:tile_value) { [1] }

        it 'raises an error' do
          expect { subject }.to(raise_error(Error::Game::ProcessingError, /already occupied on board/))
        end
      end

      context 'board is not legal after move' do
        let!(:game) { create(:game_with_user) }
        let(:move_user) { initiator_user }
        let(:row_num) { [0, 0, 0] }
        let(:col_num) { [0, 1, 2] }
        let(:tile_value) { [4, 11, 5] }

        it 'raises an error' do
          expect { subject }.to(raise_error(Error::Game::ProcessingError, /game board has no tiles on starting space/))
        end
      end

      context 'board with move is not legal' do
        # Create double digit
        let(:row_num) { [2] }
        let(:col_num) { [1] }
        let(:tile_value) { [4] }

        it 'raises an error' do
          expect { subject }.to(raise_error(Error::Game::ProcessingError, /move on board created double digit/))
        end
      end
    end

    context 'for a swap move' do
      let(:move_type) { :swap }
      let(:returned_tiles) { [1, 2, 3] }
      let(:expected_opponent_rack) { [4, 5, 6, 11] }
      let!(:expected_board) { game.board }

      it 'returns the created move' do
        new_move = subject
        expect(new_move).to(be_a(Move))
        expect(new_move.user).to(eq(opponent_user))
        expect(new_move.game).to(eq(game))
        expect(new_move.row_num).to(eq(row_num))
        expect(new_move.col_num).to(eq(col_num))
        expect(new_move.tile_value).to(eq(tile_value))
        expect(new_move.returned_tiles).to(eq(returned_tiles))
        expect(new_move.result).to(eq(10))
        expect(new_move.move_number).to(eq(2))
      end

      it 'updates the game appropriately' do
        expect do
          subject
          game.reload
        end.to(
          change { game.moves.count }.by(1)
          .and(change { game.available_tiles.count }.by(0))
        )
        expect(game.board).to(eq(expected_board))
        expect(game.initiator_score).to(eq(0))
        expect(game.opponent_rack).to(include(*expected_opponent_rack))
        expect(game.opponent_score).to(eq(10))
        expect(game.current_player).to(eq('initiator'))
        expect(game.stage).to(eq('in_play'))
      end

      it_behaves_like 'it does not post move to complete game'

      it_behaves_like 'it must be the users turn'

      it_behaves_like 'there must be move_info'

      context 'the the game is in the end-game' do
        before do
          game.available_tiles = []
          game.save!
        end

        it 'raises an error' do
          expect { subject }.to(raise_error(Error::Game::ProcessingError, /no tiles remain in game/))
        end
      end
    end

    context 'for a pass move' do
      let(:move_type) { :pass }
      let(:expected_opponent_rack) { game.opponent_rack }
      let!(:expected_board) { game.board }

      it 'returns the created move' do
        new_move = subject
        expect(new_move).to(be_a(Move))
        expect(new_move.user).to(eq(opponent_user))
        expect(new_move.game).to(eq(game))
        expect(new_move.result).to(eq(10))
        expect(new_move.move_number).to(eq(2))
      end

      it 'updates the game appropriately' do
        expect do
          subject
          game.reload
        end.to(
          change { game.moves.count }.by(1)
          .and(change { game.available_tiles.count }.by(0))
        )
        expect(game.board).to(eq(expected_board))
        expect(game.initiator_score).to(eq(0))
        expect(game.opponent_rack).to(include(*expected_opponent_rack))
        expect(game.opponent_score).to(eq(10))
        expect(game.current_player).to(eq('initiator'))
        expect(game.stage).to(eq('in_play'))
      end

      it_behaves_like 'it does not post move to complete game'

      it_behaves_like 'it must be the users turn'

      it_behaves_like 'there must be move_info'

      context 'the the game is in the end-game' do
        before do
          game.available_tiles = []
          game.save!
        end

        it 'raises an error' do
          expect { subject }.to(raise_error(Error::Game::ProcessingError, /no tiles remain in game/))
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(PlayLogic::GameLogic::GameHelpers) do
  describe 'add_move_to_board' do
    subject do
      described_class.add_move_to_board(
        board: game.board,
        move: move,
      )
    end
    let!(:game) { create(:game_with_user, :with_first_move) }
    let!(:move) do
      build(
        :move,
        row_num: rows,
        col_num: cols,
        tile_value: [1],
        game: game,
        user: game.initiator,
      )
    end
    let(:rows) { [1] }
    let(:cols) { [1] }

    it 'adds the move to the board' do
      new_board = subject.value
      expect(new_board[1][1]).to(eq(1))
    end

    context 'move space is taken' do
      let(:rows) { [2] }
      let(:cols) { [2] }

      it 'raises an error' do
        expect(subject.success?).to(be_falsey)
        expect(subject.errors.first).to(eq(:game_space_taken))
      end
    end
  end

  describe 'remove_tiles_from_rack' do
    subject do
      described_class.remove_tiles_from_rack(
        tiles: tiles,
        rack: rack,
        max: 3,
      )
    end

    let!(:tiles) { [1, 2, 3] }
    let!(:rack) { [1, 2, 3, 4, 5, 6, 7] }

    it 'removes the tiles from the rack' do
      new_rack = subject.value
      expect(new_rack).to(eq([4, 5, 6, 7]))
    end

    context 'when rack contains duplicates' do
      let!(:rack) { [1, 2, 3, 3, 5, 6, 7] }

      it 'raises an error' do
        new_rack = subject.value
        expect(new_rack).to(eq([3, 5, 6, 7]))
      end
    end

    context 'when tiles.count > max' do
      let!(:tiles) { [1, 2, 3, 4] }

      it 'raises an error' do
        expect(subject.success?).to(be_falsey)
        expect(subject.errors.first).to(eq(:game_rack_request_to_long))
      end
    end

    context 'when rack does not contain all tiles' do
      let!(:tiles) { [1, 2, 9] }

      it 'raises an error' do
        expect(subject.success?).to(be_falsey)
        expect(subject.errors.first).to(eq(:game_tiles_not_on_rack))
      end
    end
  end

  describe 'check_board_legality' do
    subject do
      described_class.check_board_legality(
        board: game.board,
      )
    end

    let!(:game) { build(:game, :with_first_move) }

    it 'returns correct value' do
      expect(subject.success?).to(eq(true))
    end

    context 'when there are no tiles on the starting space' do
      let!(:game) { build(:game, :nothing_on_starting_space) }

      it 'returns correct value' do
        result_vo = subject
        expect(result_vo.success?).to(eq(false))
        expect(result_vo.errors).to(include(:game_no_tile_on_starting))
      end
    end

    context 'when there are islands' do
      let!(:game) { build(:game, :with_islands) }

      it 'returns correct value' do
        result_vo = subject
        expect(result_vo.success?).to(eq(false))
        expect(result_vo.errors).to(include(:game_board_contains_islands))
      end
    end
  end

  describe 'check_board_with_move_legality' do
    before do
      PlayLogic::GameLogic::GameHelpers.add_move_to_board(
        board: board,
        move: move,
      )
    end

    subject do
      described_class.check_board_with_move_legality(
        board: game.board,
        move: move,
      )
    end

    let(:board) do
      [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 5, 11, 4, 0, 0, 0, 0, 0, 0],
        [0, 0, 5, 11, 4, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
      ]
    end
    let!(:game) { build(:game, board: board) }
    let!(:move) do
      build(
        :move,
        row_num: rows,
        col_num: cols,
        tile_value: tile_values,
        game: game,
        user: game.initiator,
      )
    end
    let(:rows) { [3] }
    let(:cols) { [3] }
    let(:tile_values) { [4] }

    it 'returns correct value' do
      expect(subject.success?).to(eq(true))
    end

    context 'when a move would create a double digit' do
      let(:rows) { [1] }
      let(:cols) { [2] }
      let(:tile_values) { [5] }

      it 'returns correct value' do
        result_vo = subject
        expect(result_vo.success?).to(eq(false))
        expect(result_vo.errors).to(include(:move_creates_double_digit))
      end
    end

    context 'when a move would create a double expression' do
      let(:rows) { [3, 3] }
      let(:cols) { [1, 3] }
      let(:tile_values) { [5, 4] }

      it 'returns correct value' do
        result_vo = subject
        expect(result_vo.success?).to(eq(false))
        expect(result_vo.errors).to(include(:move_creates_double_expression))
      end
    end

    context 'when a move would create a dangling operation' do
      let(:rows) { [5] }
      let(:cols) { [2] }
      let(:tile_values) { [11] }

      it 'returns correct value' do
        result_vo = subject
        expect(result_vo.success?).to(eq(false))
        expect(result_vo.errors).to(include(:move_creates_dangling_operation))
      end
    end

    context 'when a move causes lone number' do
      let(:board) do
        [
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
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

      let(:rows) { [2] }
      let(:cols) { [2] }
      let(:tile_values) { [5] }

      it 'returns correct value' do
        result_vo = subject
        expect(result_vo.success?).to(eq(false))
        expect(result_vo.errors).to(include(:move_creates_lone_integer))
      end
    end

    context 'when a move spans expressions' do
      let(:board) do
        [
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 9,  10, 9,  10, 2, 12, 2,  0, 0, 0, 0],
          [1, 11, 5,  11, 4,  0, 5,  11, 4, 0, 0, 0],
          [0, 2, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0],
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

      let(:rows) { [2, 2, 2] }
      let(:cols) { [0, 6, 8] }
      let(:tile_values) { [1, 5, 4] }

      it 'returns correct value' do
        result_vo = subject
        expect(result_vo.success?).to(eq(false))
        expect(result_vo.errors).to(include(:move_spans_expressions))
      end
    end

    context 'when a move does not include already placed tiles' do
      let(:rows) { [3, 4, 5] }
      let(:cols) { [1, 1, 1] }
      let(:tile_values) { [5, 11, 4] }

      it 'returns correct value' do
        result_vo = subject
        expect(result_vo.success?).to(eq(false))
        expect(result_vo.errors).to(include(:move_not_building))
      end

      context 'when added vertically perpendicular' do
        let(:board) do
          [
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 5, 11, 4, 0, 0, 0, 0, 0, 0],
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

        context 'above' do
          let(:rows) { [0, 1, 2] }
          let(:cols) { [4, 4, 4] }
          let(:tile_values) { [5, 11, 4] }

          it 'returns correct value' do
            result_vo = subject
            expect(result_vo.success?).to(eq(false))
            expect(result_vo.errors).to(include(:move_not_building))
          end
        end

        context 'below' do
          let(:rows) { [4, 5, 6] }
          let(:cols) { [4, 4, 4] }
          let(:tile_values) { [5, 11, 4] }

          it 'returns correct value' do
            result_vo = subject
            expect(result_vo.success?).to(eq(false))
            expect(result_vo.errors).to(include(:move_not_building))
          end
        end
      end

      context 'when added horizontally perpendicular' do
        let(:board) do
          [
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 11, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          ]
        end

        context 'above' do
          let(:rows) { [3, 3, 3] }
          let(:cols) { [0, 1, 2] }
          let(:tile_values) { [5, 11, 4] }

          it 'returns correct value' do
            result_vo = subject
            expect(result_vo.success?).to(eq(false))
            expect(result_vo.errors).to(include(:move_not_building))
          end
        end

        context 'below' do
          let(:rows) { [3, 3, 3] }
          let(:cols) { [4, 5, 6] }
          let(:tile_values) { [5, 11, 4] }

          it 'returns correct value' do
            result_vo = subject
            expect(result_vo.success?).to(eq(false))
            expect(result_vo.errors).to(include(:move_not_building))
          end
        end
      end
    end

    context 'when the move is the first move' do
      let(:board) do
        [
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
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
      let(:rows) { [2, 2, 2] }
      let(:cols) { [2, 3, 4] }
      let(:tile_values) { [5, 11, 4] }

      it 'returns correct value' do
        result_vo = subject
        expect(result_vo.success?).to(eq(true))
      end
    end
  end

  describe 'score_board_with_move' do
    before do
      PlayLogic::GameLogic::GameHelpers.add_move_to_board(
        board: board,
        move: move,
      )
    end

    subject do
      described_class.score_board_with_move(
        board: game.board,
        move: move,
      )
    end

    let(:board) do
      [
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 5, 11, 4, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
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
    let!(:game) { build(:game, board: board) }
    let!(:move) do
      build(
        :move,
        row_num: rows,
        col_num: cols,
        tile_value: tile_values,
        game: game,
        user: game.initiator,
      )
    end

    context 'when move is horizontal' do
      let(:rows) { [2, 2] }
      let(:cols) { [5, 6] }
      let(:tile_values) { [10, 3] }

      it 'returns correct value' do
        expect(subject.success?).to(eq(true))
        expect(subject.value).to(eq(3))
      end
    end

    context 'when move is vertical' do
      let(:rows) { [1, 3] }
      let(:cols) { [3, 3] }
      let(:tile_values) { [6, 3] }

      it 'returns correct value' do
        expect(subject.success?).to(eq(true))
        expect(subject.value).to(eq(2))
      end
    end
  end

  describe 'evaluate_end_game' do
    subject { described_class.evaluate_end_game(game: game) }

    let(:current_player) { 'opponent' }
    let(:available_tiles) { [] }
    let(:stage) { 'in_play' }
    let!(:game) do
      build(
        :game,
        current_player: current_player,
        available_tiles: available_tiles,
        stage: stage
      )
    end

    context 'when tiles remain' do
      let(:available_tiles) { [1] }

      it 'does not change game stage' do
        subject
        expect(game.stage).to(eq('in_play'))
      end
    end

    context 'game is already complete' do
      let(:stage) { 'complete' }

      it 'does not change game stage' do
        subject
        expect(game.stage).to(eq('complete'))
      end
    end

    context 'when the game is in play' do
      context 'when opponent is the current player' do
        it 'moves to round two' do
          subject
          expect(game.stage).to(eq('end_round_two'))
        end
      end

      context 'when initiator is the current player' do
        let(:current_player) { 'initiator' }

        it 'moves to round one' do
          subject
          expect(game.stage).to(eq('end_round_one'))
        end
      end
    end

    context 'when the game is in round one or two' do
      let(:stage) { 'end_round_one' }

      context 'when opponent is the current player' do
        it 'moves stage forward' do
          subject
          expect(game.stage).to(eq('end_round_two'))
        end
      end

      context 'when initiator is the current player' do
        let(:current_player) { 'initiator' }

        it 'does not change game stage' do
          subject
          expect(game.stage).to(eq('end_round_one'))
        end
      end
    end
  end
end

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

    context 'when tiles.count >3' do
      let!(:tiles) { [1, 2, 3, 4] }

      it 'raises an error' do
        expect(subject.success?).to(be_falsey)
        expect(subject.errors.first).to(eq(:game_rack_requrest_to_long))
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
  end
end
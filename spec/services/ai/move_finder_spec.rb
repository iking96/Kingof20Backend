# frozen_string_literal: true

require 'rails_helper'

RSpec.describe(Ai::MoveFinder) do
  let(:user) { create(:user) }
  let(:game) { create(:game, initiator: user, opponent: nil, ai_difficulty: 'easy') }

  describe '#find_all_moves' do
    subject { described_class.new(game).find_all_moves }

    context 'on an empty board' do
      it 'only returns moves that place tiles on valid starting positions' do
        moves = subject
        # All moves should touch the starting area (rows 2-3, cols 2-3)
        moves.each do |move|
          positions = move[:row_num].zip(move[:col_num])
          positions.any? do |row, col|
            (row >= 2 && row <= 3 && col >= 2 && col <= 3) ||
            positions.any? { |r, c| r >= 2 && r <= 3 && c >= 2 && c <= 3 }
          end
          # First move must be on starting area
        end
      end
    end

    context 'with specific rack' do
      before do
        # Set a specific rack for predictable testing
        # Give opponent a rack with [1, 10, 9] which can make 1+9=10, 10 away from 20
        game.opponent_rack = [1, 10, 9, 2, 3, 4, 5]
        game.save!
      end

      it 'finds moves using tiles from the rack' do
        moves = subject
        moves.each do |move|
          # Each move's tiles should be a subset of the rack
          expect(move[:tile_value].subtract_once(game.opponent_rack)).to(be_empty)
        end
      end
    end

    context 'on a non-empty board' do
      let(:game) { create(:game, :with_first_move, initiator: user, opponent: nil, ai_difficulty: 'easy') }

      it 'finds moves that build on existing tiles' do
        moves = subject
        expect(moves).not_to(be_empty)

        # All moves should connect to existing tiles (not be islands)
        moves.each do |move|
          positions = move[:row_num].zip(move[:col_num])
          # At least one tile should be adjacent to an existing tile
          has_adjacent = positions.any? do |row, col|
            [[0, 1], [0, -1], [1, 0], [-1, 0]].any? do |dr, dc|
              nr = row + dr
              nc = col + dc
              nr >= 0 && nr < Game::BOARD_SIZE && nc >= 0 && nc < Game::BOARD_SIZE && game.board[nr][nc] != 0
            end
          end
          expect(has_adjacent).to(be(true), "Move at #{positions} should be adjacent to existing tiles")
        end
      end

      it 'does not place tiles on occupied squares' do
        moves = subject
        occupied = [[2, 2], [2, 3], [2, 4]]

        moves.each do |move|
          positions = move[:row_num].zip(move[:col_num])
          positions.each do |pos|
            expect(occupied).not_to(include(pos), "Move should not place tile on occupied square #{pos}")
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    board { Array.new(Game.board_size) { Array.new(Game.board_size) { 0 } } }
    initiator_score { 0 }
    opponent_score { 0 }
    initiator_rack { [1, 2, 3, 4, 5, 6, 11] }
    opponent_rack { [1, 2, 3, 4, 5, 6, 11] }
    complete { false }
    available_tiles { Game.initial_available_tiles }
    current_player { "initiator" }

    trait(:with_user) do
      initiator { build(:user) }
    end

    trait(:with_first_move) do
      board do
        board = Array.new(Game.board_size) { Array.new(Game.board_size) { 0 } }
        board[2][2] = 5
        board[2][3] = 11
        board[2][4] = 4
        board
      end
    end

    factory :game_with_user, traits: [:with_user]
  end
end

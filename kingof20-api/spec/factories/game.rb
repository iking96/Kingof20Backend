# frozen_string_literal: true

FactoryBot.define do
  factory :game do
    board { Array.new(Game.board_size) { Array.new(Game.board_size) { 0 } } }
    initiator_score { 0 }
    opponent_score { 0 }
    initiator_rack { [1, 2, 3, 4, 5, 6, 7] }
    opponent_rack { [1, 2, 3, 4, 5, 6, 7] }
    complete { false }
    available_tiles { Game.initial_available_tiles }
    current_player { "initiator" }
  end
end

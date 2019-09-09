FactoryBot.define do
  factory :move do
    row_num { rand 0...Game.board_size }
    col_num { rand 0...Game.board_size }
    move_number { rand 0..100 }
    tile_value { Game.initial_available_tiles.sample}
  end
end

FactoryBot.define do
  factory :move do
    row_num { Array.new(3) { rand 0...Game.board_size } }
    col_num { Array.new(3) { rand 0...Game.board_size } }
    move_number { rand 0..100 }
    tile_value { Array.new(3) { Game.initial_available_tiles.sample } }
    result 0
  end
end

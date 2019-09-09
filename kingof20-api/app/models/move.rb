class Move < ApplicationRecord
  belongs_to :user, required: false
  belongs_to :game, required: false

  validates :row_num, presence: true
  validates :col_num, presence: true
  validates :move_number, presence: true
  validates :tile_value, presence: true
  validates :user, presence: true
  validates :game, presence: true
end

class Game < ApplicationRecord
  BOARD_SIZE = 12

  belongs_to :initiator, class_name: 'User', required: true
  belongs_to :opponent, class_name: 'User', required: false

  validates :board, presence: true
  validates :initiator_score, presence: true
  validates :initiator_rack, presence: true
  validates :opponent_score, presence: true
  validates :opponent_rack, presence: true
  validates :initiator_id, presence: true
  validates :current_player_id, presence: true

  # Class methods
  def self.board_size
    BOARD_SIZE
  end
end

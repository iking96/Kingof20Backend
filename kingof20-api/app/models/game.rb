# frozen_string_literal: true

class Game < ApplicationRecord
  before_validation :setup_game, on: :create

  BOARD_SIZE = 12
  INITIAL_AVAILABLE_TILES = [1, 1, 1, 1,
                             2, 2, 2, 2, 2,
                             3, 3, 3, 3,
                             4, 4, 4, 4, 4, 4,
                             5, 5, 5, 5, 5,
                             6, 6, 6, 6, 6, 6,
                             7, 7, 7, 7, 7,
                             8, 8, 8, 8, 8, 8,
                             9, 9, 9, 9,
                             10, 10, 10, 10, 10, 10, 10, 10,
                             11, 11, 11, 11, 11, 11, 11, 11,
                             12, 12, 12, 12, 12, 12, 12, 12,
                             13, 13, 13, 13, 13]

  TILES_MAPPING = {
    1 => "1",
    2 => "2",
    3 => "3",
    4 => "4",
    5 => "5",
    6 => "6",
    7 => "7",
    8 => "8",
    9 => "9",
    10 => "10",
    11 => "11",
    12 => "Minus",
    13 => "Over",
  }
  belongs_to :initiator, class_name: 'User', required: true
  belongs_to :opponent, class_name: 'User', required: false

  # Here I do delete because the move/gqe don't have any
  # clean-up unto themselves
  has_many :moves, dependent: :delete_all
  has_many :game_queue_entries, dependent: :delete_all

  validates :board, presence: true
  validates :initiator_score, presence: true
  validates :initiator_rack, presence: true
  validates :opponent_score, presence: true
  validates :opponent_rack, presence: true
  validates :initiator, presence: true

  validates :current_player, presence: true
  enum current_player: {
    initiator: 'initiator',
    opponent: 'opponent',
  }

  validates_inclusion_of :complete, in: [true, false]
  validates :available_tiles, presence: true

  validate :check_initiator_and_opponent
  def check_initiator_and_opponent
    errors.add(:initiator, "can't be the same as opponent") if initiator == opponent
  end

  # Class methods
  def self.board_size
    BOARD_SIZE
  end

  def self.initial_available_tiles
    INITIAL_AVAILABLE_TILES
  end

  def self.available_tiles_string_value(index:)
    TILES_MAPPING[index]
  end

  private

  def setup_game
    self.board ||= Array.new(Game.board_size) { Array.new(Game.board_size) { 0 } }
    self.available_tiles ||= Game.initial_available_tiles.shuffle
    self.initiator_score ||= 0
    self.initiator_rack ||= available_tiles.shift(7)
    self.opponent_score ||= 0
    self.opponent_rack ||= available_tiles.shift(7)
    self.complete ||= false if complete.nil?
    self.current_player ||= 'initiator'
  end
end

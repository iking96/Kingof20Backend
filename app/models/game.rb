# frozen_string_literal: true

class Game < ApplicationRecord
  before_validation :setup_game, on: :create

  BOARD_SIZE = 12
  RACK_SIZE = 7
  TWENTY = 20
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
    10 => "Plus",
    11 => "Times",
    12 => "Minus",
    13 => "Over",
  }

  attr_accessor :requesting_user_id

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

  validates :stage, presence: true
  enum stage: {
    in_play: 'in_play',
    end_round_one: 'end_round_one',
    end_round_two: 'end_round_two',
    complete: 'complete',
    initiator_forfit: 'initiator_forfit',
    opponent_forfit: 'opponent_forfit',
  }

  # validates .. presence: true will not allow empty array
  validates :available_tiles, exclusion: { in: [nil] }

  HIDDEN_FROM_NEITHER = 0
  HIDDEN_FROM_INITIATOR = 1
  HIDDEN_FROM_OPPONENT = 2
  HIDDEN_FROM_BOTH = 3
  validates :hidden_from, inclusion: {
    in: [
      HIDDEN_FROM_NEITHER,
      HIDDEN_FROM_INITIATOR,
      HIDDEN_FROM_OPPONENT,
      HIDDEN_FROM_BOTH,
    ],
  }

  validate :check_initiator_and_opponent
  def check_initiator_and_opponent
    errors.add(:initiator, 'initiator can\'t be the same as opponent') if initiator == opponent
  end

  def as_json(options = {})
    exclude_methods = [
      :initiator_id,
      :initiator_score,
      :initiator_rack,
      :opponent_id,
      :opponent_score,
      :opponent_rack,
      :available_tiles,
      :hidden_from,
    ]
    super(options.merge(methods: [:allow_swap?], except: exclude_methods)).tap do |hash|
      hash.merge!(requesting_user_data)
    end
  end

  def allow_swap?
    available_tiles.empty?
  end

  def complete?
    stage == 'complete' || stage == 'initiator_forfit' || stage == 'opponent_forfit'
  end

  def current_user
    if current_player == 'initiator'
      return initiator
    end

    if current_player == 'opponent'
      opponent
    end
  end

  def current_user_rack
    if current_player == 'initiator'
      return initiator_rack
    end

    if current_player == 'opponent'
      opponent_rack
    end
  end

  def current_user_score
    if current_player == 'initiator'
      return initiator_score
    end

    if current_player == 'opponent'
      opponent_score
    end
  end

  def requesting_user_data
    response_data = {}

    if requesting_user_id == initiator.id
      response_data[:you] = initiator.as_json&.except('email')
      response_data[:them] = opponent.as_json&.except('email')
      response_data[:your_rack] = initiator_rack
      response_data[:your_score] = initiator_score
      response_data[:their_score] = opponent_score
    end

    if opponent && requesting_user_id == opponent.id
      response_data[:you] = opponent.as_json&.except('email')
      response_data[:them] = initiator.as_json&.except('email')
      response_data[:your_rack] = opponent_rack
      response_data[:your_score] = opponent_score
      response_data[:their_score] = initiator_score
    end

    response_data
  end

  def requesting_user_score
    if requesting_user_id == initiator.id
      return initiator_score
    end

    if opponent && requesting_user_id == opponent.id
      opponent_score
    end
  end

  def toggle_current_user
    self.current_player = current_player == 'initiator' ? 'opponent' : 'initiator'
  end

  def refill_current_user_rack
    if current_player == 'initiator'
      self.initiator_rack += available_tiles.shift(RACK_SIZE - initiator_rack.size)
    end

    if current_player == 'opponent'
      self.opponent_rack += available_tiles.shift(RACK_SIZE - opponent_rack.size)
    end
  end

  def set_current_user_rack(new_rack:) # rubocop:disable Naming/AccessorMethodName
    if current_player == 'initiator'
      self.initiator_rack = new_rack
    end

    if current_player == 'opponent'
      self.opponent_rack = new_rack
    end
  end

  def set_current_user_score(new_score:) # rubocop:disable Naming/AccessorMethodName
    if current_player == 'initiator'
      self.initiator_score = new_score
    end

    if current_player == 'opponent'
      self.opponent_score = new_score
    end
  end

  def forfit_user(user:)
    if user == initiator
      self.stage = 'initiator_forfit'
    else
      self.stage = 'opponent_forfit'
    end
  end

  def hide_from_user(user:)
    if user == initiator
      self.hidden_from |= 1
    else
      self.hidden_from |= 2
    end
  end

  # Class methods
  def self.board_size
    BOARD_SIZE
  end

  def self.rack_size
    RACK_SIZE
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
    self.initiator_rack ||= available_tiles.shift(RACK_SIZE)
    self.opponent_score ||= 0
    self.opponent_rack ||= available_tiles.shift(RACK_SIZE)
    self.stage ||= 'in_play'
    self.current_player ||= 'initiator'
    self.hidden_from ||= 0
  end
end

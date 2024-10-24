# frozen_string_literal: true

class Move < ApplicationRecord
  belongs_to :user, required: false
  belongs_to :game, required: false

  validates :move_type, presence: true
  enum :move_type, {
    tile_placement: 'tile_placement',
    swap: 'swap',
    pass: 'pass',
  }

  validates :row_num, presence: true, if: :tile_placement?
  validates :col_num, presence: true, if: :tile_placement?
  validates :tile_value, presence: true, if: :tile_placement?

  validates :returned_tiles, presence: true, if: :swap?

  validates :move_number, presence: true
  validates :result, presence: true
  validates :user, presence: true
  validates :game, presence: true

  validate :pre_processing_valid?, on: :pre_processing
  def pre_processing_valid?
    unless PlayLogic::MoveLogic::MoveHelpers.move_pre_processor(move: self).success?
      errors.add(:base, 'move preprocesses returned false')
    end
  end

  def tile_placement?
    move_type == 'tile_placement'
  end

  def swap?
    move_type == 'swap'
  end

  def pass?
    move_type == 'pass'
  end

  def as_json(options = {})
    exclude_methods = [
      :user_id,
    ]
    super(options.merge(except: exclude_methods)).tap do |hash|
      hash.merge!(username: user.username)
    end
  end
end

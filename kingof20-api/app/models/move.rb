# frozen_string_literal: true

class Move < ApplicationRecord
  belongs_to :user, required: false
  belongs_to :game, required: false

  validates :type, presence: true
  enum type: {
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

  validate :pre_processing_valid?
  def pre_processing_valid?
    if tile_placement?
      if !row_num.present? || !col_num.present? || !tile_value.present?
        errors.add(:base, 'missing arguments for pre-processing')
        return
      end
      errors.add(:row_num, 'row input size must be less than or equal 3') unless row_num.count <= 3
      errors.add(:col_num, 'col input size must be less than or equal 3') unless col_num.count <= 3
      errors.add(:tile_value, 'tile_value size input must be less than or equal 3') unless tile_value.count <= 3
      unless row_num.count == col_num.count && col_num.count == tile_value.count
        errors.add(:base, 'row, col and tile_value input must be same length')
      end
      unless row_num.all? { |row| (0..Game.board_size).include?(row) }
        errors.add(:row_num, "row numbers must be in: [0..#{Game.board_size}]")
      end
      unless col_num.all? { |col| (0..Game::BOARD_SIZE).include?(col) }
        errors.add(:col_num, "col numbers must be in: [0..#{Game.board_size}]")
      end
      unless tile_value.all? { |tile| Game::TILES_MAPPING.keys.include?(tile) }
        errors.add(:tile_value, "tile values must be in: #{Game::TILES_MAPPING.keys}")
      end
    elsif swap?
      unless returned_tiles.present?
        errors.add(:base, 'missing arguments for pre-processing')
        return
      end
      unless returned_tiles.count <= Game.rack_size
        errors.add(:returned_tiles, "returned tiles size must be less than or equal #{Game.rack_size}")
      end
      unless returned_tiles.all? { |tile| Game::TILES_MAPPING.keys.include?(tile) }
        errors.add(:returned_tiles, "returned tiles values must be in: #{Game::TILES_MAPPING.keys}")
      end
    end

    # No additional checks needed for pass

    errors.add(:game, "id #{game_id} does not exist in Game") unless Game.exists?(id: game_id)
  end

  private

  def tile_placement?
    type == 'tile_placement'
  end

  def swap?
    type == 'swap'
  end

  def pass?
    type == 'pass'
  end
end

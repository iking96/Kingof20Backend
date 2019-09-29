# frozen_string_literal: true

class AddMoveNumberToMove < ActiveRecord::Migration[5.2]
  def change
    add_column(:moves, :move_number, :integer)
  end
end

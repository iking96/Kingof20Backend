# frozen_string_literal: true

class CreateMoves < ActiveRecord::Migration[5.2]
  def change
    create_table :moves do |t|
      t.integer(:row_num, array: true)
      t.integer(:col_num, array: true)
      t.integer(:tile_value, array: true)
      t.references(:user, index: true, foreign_key: true)
      t.references(:game, index: true, foreign_key: true)

      t.timestamps
    end
  end
end

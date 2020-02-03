# frozen_string_literal: true

class AddTypeAndReturnedTilesToMove < ActiveRecord::Migration[5.2]
  def change
    change_table :moves do |t|
      t.string(:type, index: true)
      t.integer(:returned_tiles, array: true)
    end
  end
end

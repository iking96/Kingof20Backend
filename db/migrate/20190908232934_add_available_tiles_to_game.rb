# frozen_string_literal: true

class AddAvailableTilesToGame < ActiveRecord::Migration[5.2]
  def change
    change_table :games do |t|
      t.integer(:available_tiles, array: true)
      t.boolean(:complete, index: true, default: false)
    end
  end
end

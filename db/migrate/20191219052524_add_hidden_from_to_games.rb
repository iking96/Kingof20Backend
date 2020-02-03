# frozen_string_literal: true

class AddHiddenFromToGames < ActiveRecord::Migration[5.2]
  def change
    change_table :games do |t|
      t.integer(:hidden_from, index: true, default: 0)
    end
  end
end

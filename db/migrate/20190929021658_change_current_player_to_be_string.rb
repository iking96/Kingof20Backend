# frozen_string_literal: true

class ChangeCurrentPlayerToBeString < ActiveRecord::Migration[5.2]
  def down
    change_table :games do |t|
      t.remove(:current_player)
      t.references(:current_player, index: true, foreign_key: { to_table: :users })
    end
  end

  def up
    change_table :games do |t|
      t.remove(:current_player_id)
      t.string(:current_player, index: true, default: "initiator")
    end
  end
end

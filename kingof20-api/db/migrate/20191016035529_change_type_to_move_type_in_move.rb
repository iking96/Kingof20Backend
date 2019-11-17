# frozen_string_literal: true

class ChangeTypeToMoveTypeInMove < ActiveRecord::Migration[5.2]
  def change
    change_table :moves do |t|
      t.remove(:type)
      t.string(:move_type, index: true)
    end
  end
end

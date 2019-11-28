# frozen_string_literal: true

class ChangeCompleteToString < ActiveRecord::Migration[5.2]
  def down
    change_table :games do |t|
      t.remove(:stage)
      t.boolean(:complete, index: true, default: false)
    end
  end

  def up
    change_table :games do |t|
      t.remove(:complete)
      t.string(:stage, index: true, default: "in_play")
    end
  end
end

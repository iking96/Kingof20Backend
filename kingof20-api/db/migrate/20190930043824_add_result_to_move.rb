# frozen_string_literal: true

class AddResultToMove < ActiveRecord::Migration[5.2]
  def change
    add_column(:moves, :result, :integer)
  end
end

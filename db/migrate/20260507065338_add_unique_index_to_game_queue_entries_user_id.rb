# frozen_string_literal: true

class AddUniqueIndexToGameQueueEntriesUserId < ActiveRecord::Migration[8.0]
  def change
    remove_index :game_queue_entries, :user_id
    add_index :game_queue_entries, :user_id, unique: true
  end
end
